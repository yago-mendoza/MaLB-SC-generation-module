# Tried using GROQ

# from langchain_community.chat_models import ChatOllama
# from langchain_groq import ChatGroq
# from langchain_community.chat_models import ChatOllama, ChatPromptTemplate

# llm_local = ChatOllama(model="mistral-instruct")
# llm_groq = ChatGroq(
#     groq_api_key="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",
#     # https://console.groq.com/keys
#     model_name='mixtral-87b-32768'
# )

# system = "You are a helpful assistant."
# human = "{text}"
# prompt = ChatPromptTemplate.from_messages([("system", system), ("human", human)])

# chain = prompt | llm_groq
# chain.invoke({"text": "Introduce yourself."})
