from langchain_openai import ChatOpenAI
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from dotenv import load_dotenv
from datapipe import DataPipe as dp

def ZSGen(requirements, model="gpt-3.5-turbo"):

    load_dotenv()

    prompt_template = ChatPromptTemplate.from_messages(
        [
            ("system", "Eres un experto en desarrollo de contratos inteligentes. \
             Tomas un JSON de requisitos y produces un contrato inteligente completamente funcional. \
             Produce solo código, sin comentarios ni explicaciones."),
            ("user", "JSON: {requirements}\nLenguaje: {language}")
        ]
    )

    model = ChatOpenAI(model=model, temperature=0)
    parser = StrOutputParser()

    chain = prompt_template | model | parser

    smart_contract_code = chain.invoke({
        "requirements": requirements,
        "language": "Solidity"
    })
    
    return smart_contract_code


# from datapipe import DataPipe as dp
# from dotenv import load_dotenv
# from langchain_openai import ChatOpenAI
# from langchain_core.output_parsers import StrOutputParser
# from langchain_core.prompts import ChatPromptTemplate

# def ZSGen(requirements):

#     # requirements : full plain json string
    
#     load_dotenv()

#     prompt_template = ChatPromptTemplate.from_messages(
#         [
#             ("system", "You take a JSON of requirements.\
#              Then, you produce a complete fully functional smart contract.\
#              Produce just code, no comments or explanations."),
#             ("user", "JSON: {requirements}\n Language: {language}")
#         ]
#     )

#     model = ChatOpenAI(model="gpt-3.5-turbo")
#     parser = StrOutputParser()

#     chain = prompt_template | model | parser

#     smart_contract_code = chain.invoke({
#         "requirements": requirements,
#         "language": "Solidity"
#     })

#     # Save the generation into a 'contracts' folder
#     dp.set_dir('contracts')
#     solidity_file_path = dp.save(smart_contract_code, extension='sol')
    
#     return solidity_file_path, smart_contract_code