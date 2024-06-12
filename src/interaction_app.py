import streamlit as st
from openai import OpenAI
import os
from pathlib import Path

from Modules.RP.coordinator import CoordinationTeam
from Modules.RP.parser import ParsingTeam

import pandas as pd
import json
from st_aggrid import AgGrid, GridOptionsBuilder
from pydantic import BaseModel

def main():

    DEFAULT_MESSAGE = "Greetings. Please, provide a detailed description of the contract so we can start our work."

    # ------------------ Manager Configuration ------------------ #

    def get_manager():
        if 'manager' not in st.session_state:
            st.session_state.manager = CoordinationTeam()
            st.session_state.manager.reset()
        return st.session_state.manager
    
    def clear_chat_history():
        get_manager().reset()
        st.session_state.messages = [{"role": "assistant", "content": DEFAULT_MESSAGE}]

    # ------------------ Streamlit UI Configuration ------------------ #
    
    openai_logo_dir = Path("Modules/RP/assets/openai-2.svg")
    sony_logo_dir = Path("Modules/RP/assets/SONY.png")

    with open(openai_logo_dir, "r") as file: page_icon = file.read()

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

            openai_api_key = st.text_input(
                'Enter your OpenAI API key:',
                type='password',
                help="You can find your OpenAI API key on the [OpenAI dashboard](https://platform.openai.com/account/api-keys).",
            )
            if openai_api_key:
                if not (openai_api_key.startswith('sk-') and len(openai_api_key) == 56):
                    st.warning('Please enter valid OpenAI credentials (starts with sk- and 56 characters long)', icon='⚠️')
                else:
                    st.session_state.api_key = openai_api_key
                    os.environ['OPENAI_API_TOKEN'] = openai_api_key
                    st.success('API key saved successfully! Proceed to entering your prompt message.', icon='✅')

                    get_manager().initialize_modules(
                        api_key=st.session_state.api_key,
                        model=st.session_state.selected_model,
                    )  

            # Add model selection input field to the sidebar
            selected_model = st.selectbox(
                "Select the model you would like to use:",
                ["gpt-3.5-turbo-0125", "gpt-4", "gpt-4-turbo", "gpt-4o"],
                key="selected_model",
                help="OpenAI have moved to continuous model upgrades so `gpt-3.5-turbo`, `gpt-4` and `gpt-4-turbo` point to the latest available version of each model.",
            )

    st.sidebar.title("Temperature")

    st.sidebar.header("About")

    json_path = Path(__file__).parent / 'Modules' / 'RP' / 'strings.json'
    with open(json_path, 'r') as f: strings = json.load(f)

    with st.sidebar:
        st.markdown(strings["sidebar"]["welcome"])
        st.markdown(strings["sidebar"]["description"])

    st.sidebar.header(strings["sidebar"]["example_description_header"])

    with st.sidebar:
        st.markdown(strings["sidebar"]["example_description"])
        st.markdown(strings["sidebar"]["example_content"])
        st.markdown(strings["sidebar"]["debugging_description"])
        st.markdown(strings["sidebar"]["debugging_content"])
        st.markdown(strings["sidebar"]["final_debugging"])
        st.markdown(strings["sidebar"]["final_debugging_content"])
        st.markdown(strings["sidebar"]["divider"])

    st.sidebar.header(strings["sidebar"]["faqs_header"])

    with st.sidebar:
        st.markdown(strings["sidebar"]["faq_1"])
        st.markdown(strings["sidebar"]["faq_2"])
        st.markdown(strings["sidebar"]["faq_3"])
        st.markdown(strings["sidebar"]["faq_4"])
        st.markdown(strings["sidebar"]["faq_5"])
        st.markdown(strings["sidebar"]["faq_6"])


    # ------------------ Main Page ------------------ #

    st.title("🔗 Requirement Parser")
    ChatTab, HistoryTab, ParserTab = st.tabs(["Chat", "History", "Parser"])

    with ChatTab:

        if "messages" not in st.session_state:
            st.session_state["messages"] = [{"role": "assistant", "content": DEFAULT_MESSAGE}]

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


            if st.session_state["procedure_type"] == "Vanilla Completion Generation":

                # Vanilla Completion (no streaming) ----------------------- #

                client = OpenAI(api_key=st.session_state['api_key'])
                response = client.chat.completions.create(
                    model=st.session_state["selected_model"],
                    messages=st.session_state.messages
                    )
                msg = response.choices[0].message.content

            elif st.session_state["procedure_type"] == "MaLB-SC Workflow":

                # MaLB Completion (greedy algorithm) ----------------------- #

                msg = get_manager().send(st.session_state.messages)

            st.session_state.messages.append({"role": "assistant", "content": msg})
            st.rerun()

        if submit_button and prompt:
            if not st.session_state.get('api_key'):
                st.info("Please add your OpenAI API key to continue.")
                st.stop()
            
            st.session_state.messages.append({"role": "user", "content": prompt})
            st.rerun()
            
        st.markdown("---")        

        c1, c2 = st.columns([1, 5])

        with c1:
            st.button('Clear Chat History', on_click=clear_chat_history)

        with c2:
            procedure_type = st.selectbox(
                label="Select the mechanism",
                options=[
                    "MaLB-SC Workflow",
                    "Vanilla Completion Generation",
                ],
            )
            st.session_state["procedure_type"] = procedure_type
    
    if "selected_description" not in st.session_state:
        st.session_state["selected_description"] = None

    def parse_description(obj):
        st.session_state["selected_description"] = obj
                
    with HistoryTab:

        PARSER_BUTTONS = []

        descriptions_log = []
        questions_log = []

        for label, obj, dt in get_manager().BACK_DATA:

            str_datetime = dt.strftime("%H:%M:%S")

            if label in ["System Updated Description", "Initial User Description"]:
                
                c1, c2 = st.columns([1, 5])
                with c1:
                    parser_button_label = f"Generate mid components for @{str_datetime} output"
                    st.button(parser_button_label, on_click = parse_description, args=(obj,))
                    PARSER_BUTTONS.append((parser_button_label, obj,))
                with c2:
                    st.expander(f'Back Data @{str_datetime} | {label}', expanded=True).write(obj)
                descriptions_log.append({'label':label, 'obj':obj, 'dt':dt})

            else:
                st.expander(f'Back Data @{str_datetime} | {label}', expanded=True).write(obj)
                questions_log.append({'label':label, 'obj':obj, 'dt':dt})
            
            execution_log = {"questions": questions_log, "descriptions": descriptions_log}
            dp.save(execution_log, dir=dp.interaction_logs_dir, extension='json')
    
    with ParserTab:
        if st.session_state.get("selected_description"):  # Ensuring the key exists and has value
            
            with st.expander("Selected Description"):
                st.write(st.session_state["selected_description"])
            
            requirements = ParsingTeam().get_requirements(st.session_state["selected_description"])
            attributes = ParsingTeam().get_attributes(requirements, st.session_state["selected_description"])

            # Saving "attributes" and "description" at @storage folder ###########

            from datapipe import DataPipe as dp # saves a dictionnary
            dp.save(attributes, dir=dp.interaction_attributes_dir, extension='json')

            description = st.session_state["selected_description"] # will simply save a sttring
            dp.save(description, dir=dp.interaction_descriptions_dir, extension='json') 

            ################
            
            st.subheader("Inferred Requirements")
            st.write(requirements)

            st.subheader(" ⤷  Structured Requirement Attributes")

            # Including "All" in the selection box
            options = ["All"] + requirements
            selected_requirement = st.selectbox("Select Requirement", options)

            # Function to convert attribute data to DataFrame
            def attribute_to_dataframe(attribute_value, attribute_name):
                rows = []
                if isinstance(attribute_value, list):
                    for i, item in enumerate(attribute_value):
                        if isinstance(item, (dict, BaseModel)):
                            item = json.dumps(item.dict() if isinstance(item, BaseModel) else item)
                        rows.append({attribute_name: item, "Index": i})
                else:
                    rows.append({attribute_name: attribute_value})
                return pd.DataFrame(rows)

            # Function to display DataFrame in AgGrid
            def display_aggrid(df):
                gb = GridOptionsBuilder.from_dataframe(df)
                gb.configure_default_column(groupable=True, value=True, enableRowGroup=True, editable=True)
                gb.configure_grid_options(domLayout='autoHeight')
                gridOptions = gb.build()
                height = 34 + len(df) * 28  # Dynamic height calculation
                AgGrid(df, gridOptions=gridOptions, height=min(height, 400), fit_columns_on_grid_load=True)

            # Handling display logic based on selected requirement
            if selected_requirement == "All":
                for attr in attributes:
                    st.markdown(f"##### : {attr.Name}")
                    for key, value in attr.dict().items():
                        df = attribute_to_dataframe(value, key)
                        display_aggrid(df)
            else:
                req_attributes = next((attr for attr in attributes if attr.Name == selected_requirement), None)
                if req_attributes:
                    for key, value in req_attributes.dict().items():
                        df = attribute_to_dataframe(value, key)
                        display_aggrid(df)
        else:
            st.write("No description selected yet.")
        
        
if __name__ == "__main__":
    main()

    
    