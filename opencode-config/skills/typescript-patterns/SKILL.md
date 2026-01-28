---
name: typescript-patterns
description: TypeScript best practices, type patterns, and common idioms for production code.
license: MIT
metadata:
  category: language
  priority: medium
---

# TypeScript Best Practices

## Type Definitions

### Basic Types

```typescript
// Primitives
const name: string = "Alice";
const age: number = 30;
const isActive: boolean = true;

// Arrays
const numbers: number[] = [1, 2, 3];
const names: Array<string> = ["Alice", "Bob"];

// Objects
interface User {
  id: number;
  email: string;
  name: string;
  createdAt: Date;
}

// Optional properties
interface Config {
  host: string;
  port?: number;  // Optional
  timeout?: number;
}

// Readonly
interface Point {
  readonly x: number;
  readonly y: number;
}
```

### Union and Intersection

```typescript
// Union types
type Status = "pending" | "approved" | "rejected";
type ID = string | number;

// Discriminated unions
type Result<T> = 
  | { success: true; data: T }
  | { success: false; error: string };

function handleResult(result: Result<User>) {
  if (result.success) {
    console.log(result.data);  // TypeScript knows data exists
  } else {
    console.log(result.error);  // TypeScript knows error exists
  }
}

// Intersection types
type Employee = User & {
  department: string;
  salary: number;
};
```

### Generics

```typescript
// Generic function
function first<T>(items: T[]): T | undefined {
  return items[0];
}

// Generic interface
interface Repository<T> {
  get(id: string): Promise<T | null>;
  save(item: T): Promise<T>;
  delete(id: string): Promise<void>;
}

// Generic with constraints
interface HasId {
  id: string;
}

function findById<T extends HasId>(items: T[], id: string): T | undefined {
  return items.find(item => item.id === id);
}
```

### Utility Types

```typescript
interface User {
  id: number;
  email: string;
  name: string;
  password: string;
}

// Partial - all properties optional
type UserUpdate = Partial<User>;

// Pick - select specific properties
type UserPublic = Pick<User, "id" | "email" | "name">;

// Omit - exclude properties
type UserCreate = Omit<User, "id">;

// Required - all properties required
type UserComplete = Required<User>;

// Readonly - all properties readonly
type UserReadonly = Readonly<User>;

// Record - object with specific key/value types
type UserRoles = Record<string, "admin" | "user" | "guest">;
```

## Type Guards

```typescript
// Type predicate
function isUser(value: unknown): value is User {
  return (
    typeof value === "object" &&
    value !== null &&
    "id" in value &&
    "email" in value
  );
}

// Usage
function process(data: unknown) {
  if (isUser(data)) {
    console.log(data.email);  // TypeScript knows it's User
  }
}

// Discriminated union guard
type Shape = 
  | { kind: "circle"; radius: number }
  | { kind: "rectangle"; width: number; height: number };

function area(shape: Shape): number {
  switch (shape.kind) {
    case "circle":
      return Math.PI * shape.radius ** 2;
    case "rectangle":
      return shape.width * shape.height;
  }
}
```

## Async Patterns

```typescript
// Async function return types
async function fetchUser(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  return response.json();
}

// Error handling
async function safeFetch<T>(url: string): Promise<Result<T>> {
  try {
    const response = await fetch(url);
    if (!response.ok) {
      return { success: false, error: `HTTP ${response.status}` };
    }
    const data = await response.json();
    return { success: true, data };
  } catch (error) {
    return { success: false, error: String(error) };
  }
}

// Parallel execution
async function fetchAll(ids: string[]): Promise<User[]> {
  const promises = ids.map(id => fetchUser(id));
  return Promise.all(promises);
}
```

## Classes

```typescript
class UserService {
  private readonly repository: UserRepository;
  
  constructor(repository: UserRepository) {
    this.repository = repository;
  }
  
  async getUser(id: string): Promise<User | null> {
    return this.repository.get(id);
  }
  
  async createUser(data: UserCreate): Promise<User> {
    const user: User = {
      id: generateId(),
      ...data,
    };
    return this.repository.save(user);
  }
}

// With parameter properties (shorthand)
class OrderService {
  constructor(
    private readonly orderRepo: OrderRepository,
    private readonly userService: UserService
  ) {}
}
```

## React Patterns (if applicable)

```typescript
// Component props
interface ButtonProps {
  label: string;
  onClick: () => void;
  variant?: "primary" | "secondary";
  disabled?: boolean;
}

const Button: React.FC<ButtonProps> = ({ 
  label, 
  onClick, 
  variant = "primary",
  disabled = false 
}) => {
  return (
    <button 
      onClick={onClick} 
      className={variant}
      disabled={disabled}
    >
      {label}
    </button>
  );
};

// Generic component
interface ListProps<T> {
  items: T[];
  renderItem: (item: T) => React.ReactNode;
  keyExtractor: (item: T) => string;
}

function List<T>({ items, renderItem, keyExtractor }: ListProps<T>) {
  return (
    <ul>
      {items.map(item => (
        <li key={keyExtractor(item)}>{renderItem(item)}</li>
      ))}
    </ul>
  );
}
```

## Common Patterns

### Builder Pattern

```typescript
class QueryBuilder {
  private filters: string[] = [];
  private orderBy?: string;
  private limitValue?: number;
  
  where(condition: string): this {
    this.filters.push(condition);
    return this;
  }
  
  order(field: string): this {
    this.orderBy = field;
    return this;
  }
  
  limit(n: number): this {
    this.limitValue = n;
    return this;
  }
  
  build(): string {
    let query = "SELECT * FROM table";
    if (this.filters.length) {
      query += ` WHERE ${this.filters.join(" AND ")}`;
    }
    if (this.orderBy) {
      query += ` ORDER BY ${this.orderBy}`;
    }
    if (this.limitValue) {
      query += ` LIMIT ${this.limitValue}`;
    }
    return query;
  }
}

// Usage
const query = new QueryBuilder()
  .where("status = 'active'")
  .order("created_at DESC")
  .limit(10)
  .build();
```

### Null Coalescing and Optional Chaining

```typescript
// Optional chaining
const name = user?.profile?.name;

// Nullish coalescing
const port = config.port ?? 3000;

// Combining both
const displayName = user?.name ?? "Anonymous";

// With function calls
const result = callback?.();
```

## Strict Mode Recommendations

```json
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true
  }
}
```
