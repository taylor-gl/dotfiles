#!/usr/bin/env python3

import argparse
import difflib
import openai
import os
import re
import subprocess
import textstat
import time
import uno
from com.sun.star.beans import PropertyValue
from com.sun.star.uno import Exception as UnoException
from com.sun.star.lang import IllegalArgumentException
from odf.opendocument import load
from odf.text import P, Span

FILTERING_DOCUMENT_PATH = "/tmp/filtering.odt"
SPELLING_AND_GRAMMAR_DOCUMENT_PATH = "/tmp/spelling_and_grammar.odt"
BEFORE_DOCUMENT_PATH = "/tmp/before.odt"
COMPARISON_PATH = "/tmp/comparison.odt"
MODEL = "gpt-4-1106-preview"

SPELLING_AND_GRAMMAR_PROMPT = f"""
    You are a professional editor with advanced experience in the editing industry. Carefully correct the spelling, grammar, and punctuation of the following text. Do not make any changes except to correct typos, spelling mistakes, grammar mistakes, and punctuation mistakes. Preserve the markdown syntax where applicable.
    """

FILTERING_PROMPT = f"""I have a specific editing request focused solely on filtering. Filtering includes phrases like 'she saw' or 'he felt' that create a barrier between the reader and the action. Please identify and remove only these filtering elements. Crucially, do not alter any punctuation, even if it seems incorrect or unnecessary. Spelling and grammar should also remain untouched. The text for this precise task is:"""

def read_markdown(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        return file.read()

def chunk_text(text, chunk_size=5000):
    words = text.split()
    for i in range(0, len(words), chunk_size):
        yield ' '.join(words[i:i + chunk_size])

def query_chatgpt(prompt, text):
    content = prompt + "\n" + text
    completion = openai.ChatCompletion.create(model=MODEL, messages=[{"role": "user", "content": content}])
    return format_model_output(completion.choices[0].message.content)

def format_model_output(text):
    text = re.sub(r'\s?–\s?', ' -- ', text)
    text = re.sub(r'\s?—\s?', ' -- ', text)
    return text

def convert_markdown_to_docx(md_text, docx_path):
    with open('temp.md', 'w', encoding='utf-8') as file:
        file.write(md_text)
    subprocess.run(['pandoc', 'temp.md', '-o', docx_path])
    os.remove('temp.md')

def start_libreoffice():
    cmd = "soffice --accept='socket,host=localhost,port=2002;urp;StarOffice.ServiceManager' --norestore --nologo --nodefault"
    process = subprocess.Popen(cmd, shell=True)
    time.sleep(2)
    return process

def close_libreoffice(process):
    process.terminate()
    process.wait()

def create_property(name, value):
    prop = PropertyValue()
    prop.Name = name
    prop.Value = value
    return prop

def load_document(desktop, url, hidden=True):
    properties = [PropertyValue(Name="Hidden", Value=hidden)]
    return desktop.loadComponentFromURL(url, "_blank", 0, tuple(properties))

def save_document(document, output_url):
    properties = [PropertyValue(Name="FilterName", Value="writer8")]
    document.storeToURL(output_url, tuple(properties))
    document.dispose()

def compare_documents(original_path, revised_path, compare_documents_path):
    # NOTE to do this manually in LibreOffice Writer, use Edit > Track Changes > Compare Documents to compare the documents.
    libreoffice_process = start_libreoffice()

    local_context = uno.getComponentContext()
    resolver = local_context.ServiceManager.createInstanceWithContext("com.sun.star.bridge.UnoUrlResolver", local_context)
    context = resolver.resolve("uno:socket,host=localhost,port=2002;urp;StarOffice.ComponentContext")
    desktop = context.ServiceManager.createInstanceWithContext("com.sun.star.frame.Desktop", context)

    original_url = "file:///" + original_path
    revised_url = "file:///" + revised_path

    original_doc = load_document(desktop, original_url)
    revised_doc = load_document(desktop, revised_url)

    dispatcher = context.ServiceManager.createInstanceWithContext("com.sun.star.frame.DispatchHelper", context)
    frame = original_doc.getCurrentController().getFrame()

    compare_command = ".uno:CompareDocuments"
    compare_args = (PropertyValue(Name="URL", Value=revised_url),)
    dispatcher.executeDispatch(frame, compare_command, "", 0, compare_args)

    compare_documents_url = "file:///" + os.path.abspath(compare_documents_path)
    save_document(original_doc, compare_documents_url)

    close_libreoffice(libreoffice_process)

def identify_changes(before_text, after_text):
    sequence_matcher = difflib.SequenceMatcher(None, before_text, after_text)
    changes = []

    for tag, i1, i2, j1, j2 in sequence_matcher.get_opcodes():
        if tag != 'equal':
            changes.append((i1, i2))

    return changes

def process(file_path):
    before_text = read_markdown(file_path)
    convert_markdown_to_docx(before_text, BEFORE_DOCUMENT_PATH)

    word_count = len(before_text.split())
    flesch_score = textstat.flesch_reading_ease(before_text)
    flesch_kincaid_grade = textstat.flesch_kincaid_grade(before_text)

    print(f"The text has {word_count} words and a Flesch reading ease score of {flesch_score}, meaning it is suitable for students at or above grade {flesch_kincaid_grade}.")

    print("Checking spelling and grammar...")
    # TODO maybe I should do this part last?
    spelling_and_grammar_text = query_chatgpt(SPELLING_AND_GRAMMAR_PROMPT, before_text)
    convert_markdown_to_docx(spelling_and_grammar_text, SPELLING_AND_GRAMMAR_DOCUMENT_PATH)
    compare_documents(SPELLING_AND_GRAMMAR_DOCUMENT_PATH, BEFORE_DOCUMENT_PATH, COMPARISON_PATH)
    doc = load(COMPARISON_PATH)

    steps = [
        ("filtering", FILTERING_PROMPT, "yellow")
        # TODO highlight instances of passive voice and weak uses of the was -ing construction
        # TODO highlight starting actions (e.g. "John started to laugh")
        # TODO highlight instances of clunky wording and wordiness
    ]

    for (name, prompt, highlight_color) in steps:
          after_text = query_chatgpt(prompt, before_text)
          changes = identify_changes(before_text, after_text)
          for change in changes:
              for paragraph in doc.getElementsByType(P):
                  if change in paragraph.textContent:
                      new_span = Span(stylename=your_highlight_style)  # TODO Define your_highlight_style with the desired highlight
                      new_span.addText(change)
                      paragraph.replace(change, new_span)

    output_doc_path = file_path.rsplit(".", 1)[0] + "_edits.odt"
    doc.save(output_doc_path)
    print("Done")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="ChatGPT Spelling & Grammar Check")
    parser.add_argument("file_path", help="Path to the Markdown file to be processed")

    args = parser.parse_args()

    process(args.file_path)
