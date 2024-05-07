import glob
import json
import re


def parse_txt_to_dict(file_path):
    with open(file_path) as file:
        lines = file.readlines()

    title = ""
    descriptions = {}
    requirements = {}
    collecting_descriptions = False
    collecting_requirements = False
    req_buffer = []
    desc_counter = 1
    title_next_line = False

    for line in lines:
        line = line.strip()

        if line == "":
            continue

        if line.startswith(".title"):
            title_next_line = True  # Set flag that next line will be the title

        elif title_next_line:
            title = line  # Capture title from this line
            title_next_line = False  # Reset flag

        elif line.startswith(".description"):
            collecting_descriptions = True
            collecting_requirements = False

        elif line.startswith(".requirements"):
            collecting_descriptions = False
            collecting_requirements = True
            if req_buffer:
                req_id, req_data = parse_requirement(req_buffer)
                requirements[req_id] = req_data
                req_buffer = []

        elif collecting_descriptions:
            descriptions[f"description_{desc_counter}"] = line
            desc_counter += 1

        elif collecting_requirements:
            if line.startswith("REQ"):
                if req_buffer:
                    req_id, req_data = parse_requirement(req_buffer)
                    requirements[req_id] = req_data
                    req_buffer = []
                req_buffer.append(line)
            else:
                req_buffer.append(line)

    if req_buffer:
        req_id, req_data = parse_requirement(req_buffer)
        requirements[req_id] = req_data

    return {"title": title, "descriptions": descriptions, "requirements": requirements}


def parse_requirement(lines):
    requirement = {}
    current_key = ""
    for line in lines:
        if line.startswith("REQ"):
            requirement["id"] = line.strip()
        elif line.startswith(".."):
            parts = line.split(maxsplit=1)
            current_key = parts[0].replace("..", "").strip()
            if len(parts) > 1:  # Check if there is a value part after the key
                requirement[current_key] = parts[1].strip()
            else:
                requirement[current_key] = (
                    ""  # Initialize to empty string if no value part
                )
        else:
            # This part will append additional details to the last key if it's not starting with 'REQ' or '..'
            if current_key in requirement:
                requirement[current_key] += "" + line.strip()
            else:
                # Log or handle cases where there is a formatting error or unexpected line
                print(f"Unexpected line format or misplaced line: '{line}'")

    return requirement["id"], requirement


if __name__ == "__main__":

    output_filename = "data.json"

    files = [file for file in glob.glob("*.txt") if re.match(r"d[0-9]+\.txt", file)]
    dict_objects = [parse_txt_to_dict(file) for file in files]

    combined_dict = {}
    for index, json_obj in enumerate(dict_objects, 1):
        key = f"D{index}"  # Generate key names like "D1", "D2", etc.
        combined_dict[key] = json_obj

    def save_json(data, filename):
        with open(filename, "w", encoding="utf-8") as file:
            json.dump(data, file, indent=4, ensure_ascii=False)

    save_json(combined_dict, output_filename)
