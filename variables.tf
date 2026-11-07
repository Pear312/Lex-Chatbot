variable "region" {
  default = "us-east-1"
}

variable "hello_utterances" {
  type = list(string)

  default = [
    "Hello",
    "Hi",
    "Hey",
    "Good morning",
    "What's up",
    "Help"
  ]
}

variable "check_balance_utterances" {
  type = list(string)

  default = [
    "What's the balance in my account?",
    "Check my account balance",
    "What's the balance in my {accountType} account?",
    "How much do I have in {accountType} ?",
    "I want to check the balance",
    "Can you help me with account balance?",
    "Balance in {accountType}",
  ]
}

variable "credit_syn" {
  type = list(string)

  default = [
    "credit card",
    "visa",
    "mastercard",
    "amex",
    "american express"
  ]
}