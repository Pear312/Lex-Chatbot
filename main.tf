provider "aws" {
  region = var.region
}

// Bot role
resource "aws_iam_role" "assume_role" {
  name = "Lex-bot-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lexv2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_lexv2models_bot" "BankerBot" {
  name        = "BankerBot"
  description = "Banker Bot to help customer check their balance and make transfers."
  data_privacy {
    child_directed = false
  }
  idle_session_ttl_in_seconds = 300
  role_arn                    = aws_iam_role.assume_role.arn
  type                        = "Bot"

  tags = {
    foo = "bar"
  }
}

resource "aws_lexv2models_bot_locale" "specs" {
  bot_id                           = aws_lexv2models_bot.BankerBot.id
  locale_id                        = "en_US"
  bot_version                      = "DRAFT"
  n_lu_intent_confidence_threshold = 0.7

  voice_settings {
    voice_id = "Joanna"
    engine   = "standard"
  }
}


resource "aws_lexv2models_bot_version" "version" {
  bot_id = aws_lexv2models_bot.BankerBot.id

  locale_specification = {
    "en_US" = {
      source_bot_version = "DRAFT"
    }
  }

  depends_on = [
    aws_lexv2models_bot_locale.specs
  ]
}

resource "aws_lexv2models_intent" "Hello" {
  name        = "Hello"
  description = "Greets the user"

  bot_id      = aws_lexv2models_bot.BankerBot.id
  bot_version = aws_lexv2models_bot_locale.specs.bot_version
  locale_id   = aws_lexv2models_bot_locale.specs.locale_id

  dynamic "sample_utterance" {
    for_each = var.hello_utterances

    content {
      utterance = sample_utterance.value
    }
  }

  closing_setting {
    closing_response {
      message_group {
        message {
          plain_text_message {
            value = "Hello! I am the Banking Bot. How can I help you today?"
          }
        }
      }
    }
  }

}

resource "aws_lexv2models_intent" "fallback" {
  name                    = "FallbackIntent"
  description             = "Replaces the default fallback"
  parent_intent_signature = "AMAZON.FallbackIntent"
  
  bot_id      = aws_lexv2models_bot.BankerBot.id
  bot_version = aws_lexv2models_bot_locale.specs.bot_version
  locale_id   = aws_lexv2models_bot_locale.specs.locale_id

  initial_response_setting {
    initial_response {
      allow_interrupt = true

      message_group {
        message {
          plain_text_message {
            value = "Hmmm..."
          }
        }

        variation {
          plain_text_message {
            value = "That's odd."
          }
        }

        variation {
          plain_text_message {
            value = "Very interesting."
          }
        }
      }
    }
  }

  closing_setting {
    active = true

    closing_response {
      message_group {

        message {
          plain_text_message {
            value = "Could you try rephrasing that? I can help you check your account balance, transfer funds, or make a payment."
          }
        }

        variation {
          plain_text_message {
            value = "I'm not sure what you meant. I can help you check your account balance, transfer funds, or make a payment."
          }
        }
      }
    }
  }
}
