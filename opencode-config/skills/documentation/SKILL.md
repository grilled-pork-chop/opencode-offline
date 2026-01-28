---
name: documentation
description: Write clear technical documentation including docstrings, READMEs, API docs, and architecture documents.
license: MIT
metadata:
  category: quality
  priority: medium
---

# Documentation Standards

## Docstrings

### Python (Google Style)

```python
def calculate_shipping(
    weight: float,
    destination: str,
    express: bool = False
) -> Decimal:
    """Calculate shipping cost based on weight and destination.
    
    Uses tiered pricing based on weight brackets and destination zones.
    Express shipping adds 50% to the base cost.
    
    Args:
        weight: Package weight in kilograms. Must be > 0.
        destination: ISO 3166-1 alpha-2 country code (e.g., "US", "GB").
        express: If True, use express shipping rates.
        
    Returns:
        Total shipping cost in USD as Decimal.
        
    Raises:
        ValueError: If weight <= 0 or destination code is invalid.
        
    Example:
        >>> calculate_shipping(2.5, "US")
        Decimal('12.50')
        >>> calculate_shipping(2.5, "US", express=True)
        Decimal('18.75')
    """
```

### TypeScript (TSDoc)

```typescript
/**
 * Calculate shipping cost based on weight and destination.
 *
 * Uses tiered pricing based on weight brackets and destination zones.
 *
 * @param weight - Package weight in kilograms (must be > 0)
 * @param destination - ISO 3166-1 alpha-2 country code
 * @param options - Optional configuration
 * @param options.express - Use express shipping rates
 * @returns Total shipping cost in USD
 * @throws {ValidationError} If weight <= 0 or destination is invalid
 *
 * @example
 * ```typescript
 * const cost = calculateShipping(2.5, "US");
 * // Returns: 12.50
 *
 * const expressCost = calculateShipping(2.5, "US", { express: true });
 * // Returns: 18.75
 * ```
 */
function calculateShipping(
  weight: number,
  destination: string,
  options?: { express?: boolean }
): number {
```

## README Template

```markdown
# Project Name

Brief one-line description of what this project does.

## Features

- Key feature 1
- Key feature 2
- Key feature 3

## Installation

\`\`\`bash
# Using npm
npm install project-name

# Using pip
pip install project-name
\`\`\`

## Quick Start

\`\`\`python
from project import Client

client = Client(api_key="your-key")
result = client.do_something()
print(result)
\`\`\`

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `api_key` | string | required | Your API key |
| `timeout` | int | 30 | Request timeout in seconds |
| `retries` | int | 3 | Number of retry attempts |

## Examples

### Basic Usage

\`\`\`python
# Example code here
\`\`\`

### Advanced Usage

\`\`\`python
# More complex example
\`\`\`

## API Reference

See [API Documentation](./docs/api.md) for detailed reference.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE](./LICENSE) for details.
```

## API Documentation

### Endpoint Documentation

```markdown
## POST /api/v1/users

Create a new user account.

### Authentication

Requires API key in header: `Authorization: Bearer <api_key>`

### Request

**Headers**
| Header | Required | Description |
|--------|----------|-------------|
| Authorization | Yes | Bearer token |
| Content-Type | Yes | Must be `application/json` |

**Body**
\`\`\`json
{
  "email": "user@example.com",
  "password": "securepassword123",
  "name": "John Doe",
  "role": "user"
}
\`\`\`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| email | string | Yes | Valid email address |
| password | string | Yes | Min 8 characters |
| name | string | Yes | Display name |
| role | string | No | One of: user, admin |

### Response

**201 Created**
\`\`\`json
{
  "id": "usr_abc123",
  "email": "user@example.com",
  "name": "John Doe",
  "role": "user",
  "created_at": "2024-01-15T10:30:00Z"
}
\`\`\`

**400 Bad Request**
\`\`\`json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      {"field": "email", "message": "Invalid email format"}
    ]
  }
}
\`\`\`

**409 Conflict**
\`\`\`json
{
  "error": {
    "code": "DUPLICATE_EMAIL",
    "message": "Email already registered"
  }
}
\`\`\`

### Example

\`\`\`bash
curl -X POST https://api.example.com/v1/users \
  -H "Authorization: Bearer sk_live_xxx" \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "secret123", "name": "John"}'
\`\`\`
```

## Architecture Documentation

### ADR (Architecture Decision Record)

```markdown
# ADR-001: Use PostgreSQL for Primary Database

## Status
Accepted

## Context
We need a database for storing user data, orders, and product catalog.
Expected scale: 1M users, 10M orders/year.

## Decision
Use PostgreSQL as the primary database.

## Consequences

### Positive
- ACID compliance for financial transactions
- Rich querying capabilities (JSON, full-text search)
- Strong ecosystem and tooling
- Team familiarity

### Negative
- Vertical scaling limitations
- More complex sharding if needed later

### Neutral
- Need to manage connection pooling
- Regular maintenance (vacuum, analyze)

## Alternatives Considered

### MongoDB
- Pros: Flexible schema, horizontal scaling
- Cons: Eventual consistency concerns for orders
- Rejected: Transaction requirements

### MySQL
- Pros: Similar capabilities, team familiarity
- Cons: Weaker JSON support, licensing concerns
- Rejected: PostgreSQL has better feature set
```

### System Design Document

```markdown
# Order Processing System Design

## Overview
System for processing e-commerce orders from placement to fulfillment.

## Goals
- Process 1000 orders/minute at peak
- 99.9% availability
- Order confirmation within 5 seconds

## Non-Goals
- Payment processing (handled by Stripe)
- Inventory management (separate system)

## Architecture

\`\`\`
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Client    │────▶│  API Gateway │────▶│Order Service│
└─────────────┘     └─────────────┘     └──────┬──────┘
                                               │
                    ┌──────────────────────────┼──────────────────────────┐
                    │                          │                          │
              ┌─────▼─────┐            ┌───────▼───────┐          ┌───────▼───────┐
              │ PostgreSQL │            │  Redis Cache  │          │ Message Queue │
              └───────────┘            └───────────────┘          └───────────────┘
\`\`\`

## Components

### Order Service
- Validates order data
- Reserves inventory
- Creates order record
- Publishes to message queue

### Message Queue (RabbitMQ)
- Decouples order creation from fulfillment
- Enables retry on failure
- Handles backpressure

## Data Flow
1. Client submits order
2. API validates and authenticates
3. Order Service checks inventory
4. Order created in PostgreSQL
5. Event published to queue
6. Confirmation returned to client

## Failure Modes

| Failure | Impact | Mitigation |
|---------|--------|------------|
| Database down | Cannot create orders | Failover to replica |
| Queue down | Delayed fulfillment | Write-ahead log |
| Service crash | Temporary unavailability | Auto-restart, multiple instances |
```

## Writing Guidelines

1. **Know your audience**: Adjust detail level accordingly
2. **Lead with the important info**: Don't bury the lede
3. **Use examples**: Show, don't just tell
4. **Keep it current**: Outdated docs are worse than none
5. **Be concise**: Respect reader's time
