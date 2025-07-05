# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a household expense tracking application (kakeibo) built with Rails 7.1.5.1 and Ruby 3.2.2. The application integrates with LINE Messaging API to provide a conversational interface for managing personal finances.

## Architecture

### Core Components

- **Controllers**: `LinebotController` handles LINE webhook messages and user interactions
- **Models**: `User`, `ExpenseRecord`, `Category`, `Group` - standard Rails models with SQLite database
- **Services**: Message processing is handled by service classes in `app/services/`
  - `MessageHandler::CoreHandler` - Main message routing and processing
  - `MessageHandler::InputMessageHandler` - Handles expense/income input flow
  - `MessageHandler::ShowMessageHandler` - Handles data display requests
  - `MessageParser::*` - Classes for parsing user input messages
- **Usecases**: Business logic isolated in `app/usecases/` following Clean Architecture principles
  - `CreateExpenseRecordUsecase`, `CreateUserUsecase`, `GetMonthlyTotalUsecase`, etc.

### Data Flow

1. LINE webhook receives message → `LinebotController#callback`
2. User lookup/creation if needed
3. Message routing through `MessageHandler::CoreHandler`
4. State-based processing using `User#talk_mode` (input_mode, show_mode, group_mode, etc.)
5. Response generation and reply to LINE API

## Development Commands

### Docker Development Setup
```bash
# Start development environment
docker compose up

# Database setup
docker compose exec web bin/rails db:create
docker compose exec web bin/rails db:migrate

# Access Rails console
docker compose exec web bin/rails console

# Run tests
docker compose exec web bin/rspec

# Run specific test
docker compose exec web bin/rspec spec/path/to/test_spec.rb

# Run linting
docker compose exec web bundle exec rubocop

# Auto-fix linting issues
docker compose exec web bundle exec rubocop -a
```

### Local Development (without Docker)
```bash
# Install dependencies
bundle install

# Database setup
bin/rails db:create
bin/rails db:migrate

# Run tests
bin/rspec

# Run server
bin/rails server

# Lint code
bundle exec rubocop
```

### Model Annotations
The project uses the `annotate` gem to automatically add schema information to model files:
```bash
# Update model annotations
bundle exec annotate --models
```

### Testing
- Uses RSpec for testing with FactoryBot for test data
- Test structure follows Rails conventions: `spec/models/`, `spec/services/`, `spec/usecases/`
- Run full test suite: `bin/rspec`
- Run specific test: `bin/rspec spec/path/to/test_spec.rb`

## Key Configuration

### Environment Variables
- `LINE_CHANNEL_SECRET` - LINE Bot channel secret
- `LINE_CHANNEL_TOKEN` - LINE Bot channel access token

### Database
- Development: SQLite (`db/development.sqlite3`)
- Test: SQLite (`db/test.sqlite3`)

### LINE Integration
- Webhook endpoint: `/callback`
- Requires ngrok for local development: `ngrok http 3000`
- Set LINE webhook URL to `https://YOUR_NGROK_URL/callback`
  - Once ngrok is up and running, you will need to set the callback URL in the Messaging API settings screen, so please let us know the URL.

## Key Patterns

### Talk Modes
Users have different conversation states (`talk_mode`):
- `default_mode` - Initial state, shows main menu
- `input_mode` - Generic expense input
- `expense_input_mode` - Specific expense input
- `income_input_mode` - Income input
- `show_mode` - Data viewing/confirmation
- `group_mode` - Group management

### Service Layer
Message processing follows a service-oriented architecture:
- Handlers process different types of messages
- Parsers extract structured data from user input
- Usecases contain business logic and database operations

### Model Relationships
- `User` has many `ExpenseRecord`s
- `ExpenseRecord` belongs to `User` and `Category`
- `ExpenseRecord` uses enum for `expense_type` (expense/income)
- Soft deletion via `is_disabled` flag on `ExpenseRecord`

### How to proceed with development
- Basically, it is difficult to operate like debugging on a screen.
- Please proceed with development using TDD.

