import string

def escape_braces(s: str) -> str:
    return s.replace('{', '{{').replace('}', '}}')

def _has_placeholders(
    s: str
) -> bool:

    return '{}' in s

def _has_named_placeholders(
    s: str
) -> bool:

    try:
        parsed = string.Formatter().parse(s)
        return any(
            field_name for _, field_name, _, _ in parsed 
            if field_name
        )
    except ValueError:
        return False