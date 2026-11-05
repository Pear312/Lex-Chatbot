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