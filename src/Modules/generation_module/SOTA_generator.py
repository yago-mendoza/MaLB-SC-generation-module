from datapipe import DataPipe as dp
from dotenv import load_dotenv
from langchain_openai import ChatOpenAI
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate

def SOTA(requirements):
    
    load_dotenv()

    prompt_template = ChatPromptTemplate.from_messages(
        [
            ("system", "You take a JSON of requirements.\
             Then, you produce a complete fully functional smart contract.\
             Produce just code, no comments or explanations."),
            ("user", "JSON: {requirements}\n Language: {language}")
        ]
    )

    model = ChatOpenAI(model="gpt-3.5-turbo")
    parser = StrOutputParser()

    chain = prompt_template | model | parser

    smart_contract_code = chain.invoke({
        "requirements": requirements,
        "language": "Solidity"
    })

    # Save the generation into a 'contracts' folder
    dp.set_dir('contracts')
    solidity_file_path = dp.save(smart_contract_code, extension='sol')
    
    return solidity_file_path

if __name__ == "__main__":
    generate_smart_contract()