USER_MESSAGE_PROMPT_CREATE = """
Description: {} 
Features: {} 
Write a Smart Contract based on the Features.
"""

USER_MESSAGE_PROMPT_REVIEW = """
Contract Code: {} 
Review Aspects: {} 
Provide detailed feedback and suggestions for improvements.
"""

USER_MESSAGE_PROMPT_INQUIRY = """
Contract Code: {} 
Inquiry Aspects: {} 
Ask detailed questions to clarify the specified aspects.
"""

USER_MESSAGE_PROMPT_OBSERVATION = """
Contract Code: {} 
Observation Aspects: {} 
Generate a JSON structure that includes detailed observations.
"""

USER_MESSAGE_PROMPT_OPTIMIZATION = """
Contract Code: {} 
Optimization Aspects: {} 
Analyze and suggest optimizations for the specified aspects.
"""

USER_MESSAGE_PROMPT_BUG_FIX = """
Code Snippet: {} 
Bug Description: {} 
Identify the cause of the bug and provide a fix with an explanation.
"""

USER_MESSAGE_PROMPT_CODE_REFACTOR = """
Code Snippet: {} 
Refactor Aspects: {} 
Refactor the code to improve readability, performance, and maintainability.
"""

USER_MESSAGE_PROMPT_UNIT_TEST = """
Code Snippet: {} 
Test Scenarios: {} 
Write unit tests for the given code to ensure functionality and reliability.
"""

USER_MESSAGE_PROMPT_API_DOC = """
API Code: {} 
Documentation Requirements: {} 
Generate detailed API documentation covering endpoints, request/response formats, and usage examples.
"""

USER_MESSAGE_PROMPT_CODE_REVIEW = """
Code Snippet: {} 
Review Criteria: {} 
Perform a code review focusing on the specified criteria and provide constructive feedback.
"""

USER_MESSAGE_PROMPT_FEATURE_ADDITION = """
Code Base: {} 
New Feature Description: {} 
Integrate the new feature into the existing code base with a detailed explanation of changes.
"""

USER_MESSAGE_PROMPT_PERFORMANCE_ANALYSIS = """
Code Snippet: {} 
Performance Metrics: {} 
Analyze the performance of the code and suggest improvements to optimize execution.
"""