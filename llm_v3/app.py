# Reference: https://python.langchain.com/v0.1/docs/use_cases/question_answering/local_retrieval_qa/
from flask import Flask, render_template, request
import helpers

app = Flask(__name__)

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/process", methods=["POST"])
def process():

    filename = request.files["file"].filename
    file_path = f"./pdf/{filename}"
    docs = helpers.load_document(file_path)
    retriever = helpers.create_embeddings_and_retriever(docs)

    question = request.form["question"]

    prompt = helpers.create_prompt()
    qa = helpers.setup_retrievalqa(retriever, prompt)

    result = qa.invoke(question)
    #print(result['result'])

    return render_template("result.html", answer = result['result'])

if __name__ == "__main__":
    app.run(debug=True)