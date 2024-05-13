class ApiKeyNotFoundException(Exception):
    """Exception raised when the API key is not found in the environment variables."""

    def __init__(self, message="API key not found. Please set the GROQ_API_KEY environment variable."):
        self.message = message
        super().__init__(self.message)