class VerboseLogger:
    
    def __init__(self):
        self.verbose_prompt = f"-- {type(self).__name__} |"
        self.verbose_indent = 1

    """
    This class is not intended to be used on its own. This class provides a simple logging mechanism for verbose output, intended to be used in another class that require logging functionality. This requires that the class that inherits from verbose_logger has a verbose_policy attribute that determines the level of verbosity, and optional attributes for formatting the messages.

    >>> class MyClass(VerboseLogger):
    >>>     def __init__(self, verbose_policy=0):
    >>>         VerboseLogger.__init__(self)
    >>>         self.verbose_policy = verbose_policy  [required]
    >>>         self.verbose_prompt = "-- Datapipe"   [optional]
    >>>         self.verbose_indent = 4               [optional]

    If verbose_policy is set to 0, no output will be displayed. Otherwise, the log method will display the content provided as an argument, with the verbose level determining the amount of indentation.

    >>> self.log("This is a log message", 1)
    >>> self.log("This is a log message", 2)
    >>> self.log("This is a log message", 3)
    
    """

    def log(
        self, 
        content: str, 
        verbose_level: int = None
    ) -> None:
        if (
            isinstance(verbose_level, int) 
            and self.verbose_policy >= verbose_level
        ):
            if verbose_level == 1:
                print(self.verbose_prompt + ' ' + content)
            
            else:
                print(
                    ' ' * self.verbose_indent
                    + ' ' * self.verbose_indent * (verbose_level-2)
                    + "↳ "
                    + content
                )
