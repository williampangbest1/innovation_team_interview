from langchain_community.document_loaders import PyPDFLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_chroma import Chroma
from langchain_community.embeddings import GPT4AllEmbeddings
from langchain_community.llms import LlamaCpp
from langchain.chains import RetrievalQA
from langchain.prompts import PromptTemplate


def load_document(file_path):
    """
    Reads document and parses into text. Then, splits text into chunks for processing.
    """
    loader = PyPDFLoader(file_path)
    pages = loader.load_and_split()

    # Split Text
    text_splitter = RecursiveCharacterTextSplitter(chunk_size=3000, chunk_overlap=300)
    docs = text_splitter.split_documents(pages)

    return docs


def create_embeddings_and_retriever(docs):
    """
    Create embeddings from splitted text
    """
    # Text Embedding and store as Vector
    vectorstore = Chroma.from_documents(documents=docs,
                                        embedding=GPT4AllEmbeddings(model_name="all-MiniLM-L6-v2.gguf2.f16.gguf")
                                        )

    # Retrieve from vector database
    retriever = vectorstore.as_retriever()

    return retriever


def create_prompt():
    prompt_template = """
    Use the following pieces of context to answer the question at the end. Please summarize the following into bullet points:
    1. If you don't know the answer, don't try to make up an answer. Just say "I can't find the final answer but you may want to check the following links".

    - List the required CPT codes
    - List the required HCPCS codes
    - List the age requirements
    - List the gender requirement

    {context}

    Question: {question}

    Helpful Answer:
    """

    prompt = PromptTemplate(
        template=prompt_template, input_variables=["question", "context"]
    )

    return prompt


def setup_retrievalqa(retriever, prompt):
    """
    Set up RetrievalQA
    """

    # Set up LLM
    llm = LlamaCpp(
        model_path="llama-2-7b-chat.q4_K_M.gguf",
        temperature=0.75,
        max_tokens=512,
        top_p=1,
        n_ctx=4096,  # Context length
        verbose=True,  # Verbose is required to pass to the callback manager
    )

    qa = RetrievalQA.from_chain_type(llm=llm,
                                     chain_type="stuff",
                                     retriever=retriever,
                                     return_source_documents=True,
                                     chain_type_kwargs={"prompt": prompt})

    return qa
