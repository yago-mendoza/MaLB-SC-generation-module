import streamlit as st
from openai import OpenAI
import os
import toml
from pathlib import Path

# run with "streamlit run ui.py"

openai_logo_dir = Path("assets/openai-2.svg")
sony_logo_dir = Path("assets/SONY.png")

with open(openai_logo_dir, "r") as file: page_icon = file.read()
st.set_page_config(page_title="MaLB-SC Generation Module GUI", page_icon=page_icon)


c = st.columns(1)
st.caption("")

st.image(str(sony_logo_dir), width=100)

st.title("🔗 Requirement Parser")
st.caption("This is a testing product that primarily uses the GPT-3.5 model. As a result, the quality of interactions may vary. For enhanced performance and more accurate responses, consider using more inference-expensive models. Please note that this product is in the testing phase, and user experience improvements are ongoing.")

with st.expander("See explanation"):
    st.write("""
        The Earth orbits around the Sun in an elliptical path, with the Sun at one of the two foci of the ellipse.
        This elliptical orbit is a result of the gravitational forces between the Earth and the Sun.
    """)

# Additional content outside the expander
st.write("This is some content outside the expander.")

ChatTab, GenerationTab = st.tabs(["Chat", "Info"])

with ChatTab:
    if "messages" not in st.session_state:
        st.session_state["messages"] = [{"role": "assistant", "content": "Hello, how can I help you today?"}]

    def clear_chat_history():
        st.session_state.messages = [{"role": "assistant", "content": "How may I assist you today?"}]

    for msg in st.session_state.messages:
        st.chat_message(msg["role"]).write(msg["content"])

    # Create a form for the input prompt
    with st.form(key='chat_form', clear_on_submit=True):
        prompt = st.text_input("Your message", key="input")
        c1, c2 = st.columns([1, 4.6])
        with c1: submit_button = st.form_submit_button(label='Clear History')
        with c2: submit_button = st.form_submit_button(label='Send')

    if submit_button and prompt:

        if not st.session_state.get('api_key'):
            st.info("Please add your OpenAI API key to continue.")
            st.stop()

        client = OpenAI(api_key=st.session_state['api_key'])
        st.session_state.messages.append({"role": "user", "content": prompt})
        
        response = client.chat.completions.create(model="gpt-3.5-turbo", messages=st.session_state.messages)
        msg = response.choices[0].message.content
        st.session_state.messages.append({"role": "assistant", "content": msg})
        
        st.experimental_rerun()

with GenerationTab:
    st.write("This tab contains information.")
with st.sidebar:

    st.title('💻 MaLB-SC Generation Module')
    st.write('This chatbot is created using the GPT3.5-Turbo LLM model from OpenAI.')

    # Models and model parameters ######################
    # st.subheader('Models and parameters')
    # selected_model = st.sidebar.selectbox('Choose a Llama2 model', ['Llama2-7B', 'Llama2-13B'], key='selected_model')
    # if selected_model == 'Llama2-7B':
    #     llm = 'a16z-infra/llama7b-v2-chat:4f0a4744c7295c024a1de15e1a63c880d3da035fa1f49bfd344fe076074c8eea'
    # elif selected_model == 'Llama2-13B':
    #     llm = 'a16z-infra/llama13b-v2-chat:df7690f1994d94e96ad9d568eac121aecf50684a0b0963b25a41cc40061269e5'
    # temperature = st.sidebar.slider('temperature', min_value=0.01, max_value=1.0, value=0.1, step=0.01)
    # top_p = st.sidebar.slider('top_p', min_value=0.01, max_value=1.0, value=0.9, step=0.01)
    # max_length = st.sidebar.slider('max_length', min_value=32, max_value=128, value=120, step=8)

    SECRETS_FILE = ".streamlit/secrets.toml"

    def load_secrets():
        with open(SECRETS_FILE, 'r') as f:
            secrets = toml.load(f)
        return secrets

    def save_secret(key, value):
        secrets = load_secrets()
        secrets['OPENAI_API_KEYS'][key] = value
        with open(SECRETS_FILE, 'w') as f:
            toml.dump(secrets, f)

    # Inicializar el estado de la sesión si es necesario
    if 'api_key' not in st.session_state:
        st.session_state['api_key'] = None

    # Cargar los secretos
    secrets = load_secrets()

    if 'TESTING_KEY' in secrets['OPENAI_API_KEYS']:
        st.success('API key already provided!', icon='✅')
        st.session_state['api_key'] = secrets['OPENAI_API_KEYS']['TESTING_KEY']
        
    else:
        openai_api_key = st.text_input('OpenAI API token:', type='password')
        "[Get an OpenAI API key](https://platform.openai.com/account/api-keys)"
        if openai_api_key:
            if not (openai_api_key.startswith('sk-') or len(openai_api_key) != 56):
                st.warning('Please enter your credentials!', icon='⚠️')
            else:
                st.session_state['api_key'] = openai_api_key
                save_secret('TESTING_KEY', openai_api_key)
                st.success('API key saved successfully! Proceed to entering your prompt message.', icon='✅')

    # Usar la clave API de session_state si está definida
    if st.session_state['api_key']:
        os.environ['REPLICATE_API_TOKEN'] = st.session_state['api_key']

    

    st.sidebar.markdown("---")

    st.sidebar.button('Clear Chat History', on_click=clear_chat_history)
