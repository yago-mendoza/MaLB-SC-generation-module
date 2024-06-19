DYNAMICAL_CONTRACT_REVIEW_PROMPT = """
You have access to the following tools:
Output a JSON object with the following structure to use the tools

commands: {
    "review": {
        "methodology": "formal_verification",
        "code_part": "smart_contract_body",
        "contract_type": "singular",
        "tasks": {
            "syntax_check": true,
            "security_audit": true,
            "optimization_analysis": true,
            "compliance_check": false,
            "unit_tests": true,
            "integration_tests": false,
            "multi_contract_interaction": false
        },
        "params": {
            "description": "Perform a thorough review of the smart contract body using formal verification methods for a singular contract type.",
            "additional_notes": "Focus on identifying potential security vulnerabilities and optimization opportunities."
        }
    },
    "review": {
        "methodology": "manual_code_review",
        "code_part": "deployment_scripts",
        "contract_type": "multiple",
        "tasks": {
            "syntax_check": true,
            "security_audit": false,
            "optimization_analysis": false,
            "compliance_check": true,
            "unit_tests": false,
            "integration_tests": true,
            "multi_contract_interaction": true
        },
        "params": {
            "description": "Manually review the deployment scripts for multiple contracts, ensuring compliance with best practices and verifying multi-contract interactions.",
            "additional_notes": "Pay special attention to the accuracy of deployment parameters and scripts."
        }
    },
    "review": {
        "methodology": "automated_testing",
        "code_part": "contract_functions",
        "contract_type": "singular",
        "tasks": {
            "syntax_check": true,
            "security_audit": true,
            "optimization_analysis": true,
            "compliance_check": true,
            "unit_tests": true,
            "integration_tests": false,
            "multi_contract_interaction": false
        },
        "params": {
            "description": "Execute automated tests on the contract functions of a singular contract to ensure functionality and security.",
            "additional_notes": "Focus on validating logic correctness and compliance with security standards."
        }
    }
}
"""