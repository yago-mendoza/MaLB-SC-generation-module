import streamlit as st
from openai import OpenAI
import os
from pathlib import Path

# run with "streamlit run ui.py"

def main():

    # ------------------ Streamlit UI Configuration ------------------ #

    openai_logo_dir = Path("assets/openai-2.svg")
    sony_logo_dir = Path("assets/SONY.png")
    
    with open(openai_logo_dir, "r") as file: page_icon = file.read()

    def clear_chat_history(): st.session_state.messages = [{"role": "assistant", "content": "Could you please tell me how you'd like your smart contract to work?"}]

    st.set_page_config(
        page_title="MaLB-SC Generation Module GUI",
        page_icon=page_icon,
        layout="wide",
        initial_sidebar_state="expanded",
    )

    # ------------------ Sidebar ------------------ #
    
    st.sidebar.caption('SONY / MaLB-SC Generation Module')
    st.sidebar.title("How to use this interface")

    with st.sidebar:

        model_provider = st.selectbox(
            "Select your preferred model provider:",
            ["OpenAI API"],
            key="model_provider",
            help="Select the model provider you would like to use. This will determine the models available for selection.",
        )

        if model_provider == "OpenAI API":
            st.markdown(
            """
            1. Enter your [OpenAI API key](https://platform.openai.com/account/api-keys) and chosen model below.
            2. Select the appropriate model for design and generation purposes.
            3. Tune the settings according to your specific requirements.
            """
            )

            st.session_state['api_key'] = None

            # User Interface for API key input
            if not st.session_state['api_key']:
                openai_api_key = st.text_input(
                    'Enter your OpenAI API key:',
                    type='password',
                    help="You can find your OpenAI API key on the [OpenAI dashboard](https://platform.openai.com/account/api-keys).",
                    )
                if openai_api_key:
                    if not (openai_api_key.startswith('sk-') and len(openai_api_key) == 56):
                        st.warning('Please enter valid OpenAI credentials (starts with sk- and 56 characters long)', icon='⚠️')
                    else:
                        st.session_state['api_key'] = openai_api_key
                        os.environ['OPENAI_API_TOKEN'] = openai_api_key  # Save the API key in the environment
                        st.success('API key saved successfully! Proceed to entering your prompt message.', icon='✅')

            # Add model selection input field to the sidebar
            selected_model = st.selectbox(
                "Select the model you would like to use:",
                ["gpt-4o", "gpt-4-turbo", "gpt-4", "gpt-3.5-turbo"],
                key="selected_model",
                help="OpenAI have moved to continuous model upgrades so `gpt-3.5-turbo`, `gpt-4` and `gpt-4-turbo` point to the latest available version of each model.",
            )

    st.sidebar.title("Model Parameters")

    temperature = st.sidebar.slider('Temperature', min_value=0.01, max_value=1.0, value=1.0, step=0.01)
    top_p = st.sidebar.slider('Top P', min_value=0.01, max_value=1.0, value=1.0, step=0.01)

    st.sidebar.header("About")

    with st.sidebar:
        st.markdown(
            "Welcome to MaLB-SC, an AI-powered tool designed to help teams create robust ERC721 smart contracts for engaging with fans."
        )
        st.markdown(
            "Smart contracts are crucial in blockchain applications, ensuring secure and transparent transactions. This app leverages the power of Large Language Models (LLMs) to help you define the requirements of your smart contracts and then automatically generate the contracts based on the details provided."
        )

    st.sidebar.header("Example Application Description")

    with st.sidebar:
        st.markdown(
            "Below is an example application description that you can use to test MaLB:"
        )
        st.markdown(
            "> The contract has to manage 50,000 tokens available for a concert, with each token representing one ticket. Users are limited to purchasing one ticket each, but those with Golden status can buy up to three tickets to transfer to other users. The ticket sales are divided into two phases. The first phase lasts for 5 minutes, and the second phase is triggered one week after the first one ends. If the event is cancelled, compensation includes an extra 25% for Golden ticket holders, 5% for Platinum, and no extra compensation for Bronze ticket holders."
        )
        st.markdown("""---""")

    st.sidebar.header("FAQs")

    with st.sidebar:
        st.markdown(
            """
            ### **What is the purpose of this STREAMLIT app?**
            This app demonstrates the functionality of MaLB, a system that transforms user descriptions into smart contracts. It currently supports OpenAI's LLM but can be easily extended to support other LLMs like Google's Gemini, or open-source models such as Llama or Mistral, thanks to the DSPy framework.
            """
        )

        st.markdown(
            """
            ### **What is MaLB?**
            MaLB is a system designed to convert user descriptions into smart contracts. It leverages Large Language Models (LLMs) to interpret natural language inputs and generate corresponding smart contracts.
            """
        )

        st.markdown(
            """
            ### **Which LLMs are currently supported by MaLB?**
            Currently, MaLB supports OpenAI's LLM. However, the framework is designed to be flexible, allowing easy integration of other LLMs like Google's Gemini or open-source models such as Llama or Mistral.
            """
        )

        st.markdown(
            """
            ### **What are the cost considerations for using different LLMs?**
            It's important to note that models like GPT-4 or GPT-40 are significantly more expensive, costing 30 to 60 times more than GPT-3.5. Users should consider these costs when choosing a model for their needs.
            """
        )

        st.markdown(
            """
            ### **Is MaLB fully developed?**
            No, MaLB is still under development. The current version provides a simple way to interact with the chatbot and see how user descriptions can be converted into smart contracts.
            """
        )

        st.markdown(
            """
            ### **How can I use this app?**
            To use the app, simply enter your description into the provided input field. The system will process your input using the integrated LLM and generate a corresponding smart contract.
            """
        )

    # ------------------ Main Page ------------------ #

    # st.image(str(sony_logo_dir), width=100)

    st.title("🔗 Requirement Parser")
    ChatTab, DataTab = st.tabs(["Chat", "Data"])

    with ChatTab:

        if "messages" not in st.session_state:
            st.session_state["messages"] = [{"role": "assistant", "content": "Hello, how can I help you today?"}]

        st.markdown(
            """
        <style>
        button {
            padding-left: 30px !important;
            padding-right: 30px !important;
            padding-top: 20px !important;
            padding-bottom: 20px !important;
        }
        </style>
        """,
            unsafe_allow_html=True,
        )

        # Create a form for the input prompt
        with st.form(key='chat_form', clear_on_submit=True):
            instructionCol, buttonCol = st.columns([10,1])
            with instructionCol:
                prompt = st.text_input("Your message", key="input")
            with buttonCol:
                submit_button = st.form_submit_button(label='Send')
        
        for msg in st.session_state.messages[::-1]:
            st.chat_message(msg["role"]).write(msg["content"])
        
        if st.session_state.messages[-1]["role"] == "user":

            client = OpenAI(api_key=st.session_state['api_key'])

            # Vanilla Completin (no streaming) ----------------------- #
            
            response = client.chat.completions.create(model="gpt-3.5-turbo", messages=st.session_state.messages)
            msg = response.choices[0].message.content
            st.session_state.messages.append({"role": "assistant", "content": msg})
            st.experimental_rerun()

        if submit_button and prompt:
            if not st.session_state.get('api_key'):
                st.info("Please add your OpenAI API key to continue.")
                st.stop()
            
            st.session_state.messages.append({"role": "user", "content": prompt})
            st.experimental_rerun()
            
        st.markdown("---")        

        c1, c2 = st.columns([1, 5])

        with c1:
            st.button('Clear Chat History', on_click=clear_chat_history)

        with c2:
            app_type = st.selectbox(
                label="Select the mechanism",
                options=[
                    "Vanilla Completion Generetion",
                    "MaLB-SC Workflow",
                ],
                key="procedure",
            )
            
    with DataTab:
        st.write('Data')

if __name__ == "__main__":
    main()

    
    