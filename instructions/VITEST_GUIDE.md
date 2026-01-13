# Vitest Testing Guide

A comprehensive guide to writing fast, modern unit and integration tests with Vitest.

## Table of Contents

1. [Installation & Setup](#installation--setup)
2. [Project Structure](#project-structure)
3. [Configuration](#configuration)
4. [Writing Tests](#writing-tests)
5. [Assertions](#assertions)
6. [Mocking](#mocking)
7. [Snapshots](#snapshots)
8. [Test Context & Fixtures](#test-context--fixtures)
9. [Code Coverage](#code-coverage)
10. [Test Environments](#test-environments)
11. [Type Testing](#type-testing)
12. [Projects & Workspaces](#projects--workspaces)
13. [Reporters](#reporters)
14. [Debugging](#debugging)
15. [Migration from Jest](#migration-from-jest)
16. [Best Practices](#best-practices)

---

## Installation & Setup

### Quick Start

```bash
# Using npm
npm install -D vitest

# Using yarn
yarn add -D vitest

# Using pnpm
pnpm add -D vitest

# Using bun
bun add -D vitest
```

Add a test script to `package.json`:

```json
{
  "scripts": {
    "test": "vitest",
    "test:run": "vitest run",
    "test:ui": "vitest --ui",
    "coverage": "vitest run --coverage"
  }
}
```

### System Requirements

- **Node.js**: 20.x, 22.x, or 24.x
- **Vite**: 5.x or 6.x (optional, but recommended)

### Why Vitest?

- **Vite-Powered**: Leverages Vite's fast dev server, HMR, and plugin ecosystem
- **Jest Compatible**: Drop-in replacement with familiar API
- **Out-of-box ESM/TypeScript/JSX**: No additional configuration needed
- **Smart Watch Mode**: Only reruns affected tests on file changes
- **Native Parallel Execution**: Tests run in isolated worker processes

---

## Project Structure

A typical Vitest project structure:

```
├── vitest.config.ts         # Vitest configuration
├── package.json             # Project dependencies
├── src/
│   ├── utils.ts             # Source files
│   └── utils.test.ts        # Co-located tests (optional)
├── tests/
│   ├── unit/
│   │   └── example.test.ts  # Unit tests
│   └── integration/
│       └── api.test.ts      # Integration tests
└── coverage/                # Coverage reports (generated)
```

---

## Configuration

### Basic Configuration (`vitest.config.ts`)

```typescript
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    // Test file patterns
    include: ['**/*.{test,spec}.{js,mjs,cjs,ts,mts,cts,jsx,tsx}'],
    exclude: ['**/node_modules/**', '**/dist/**'],

    // Environment
    environment: 'node', // 'node' | 'jsdom' | 'happy-dom' | 'edge-runtime'

    // Global APIs (jest-like)
    globals: true,

    // Coverage
    coverage: {
      provider: 'v8', // or 'istanbul'
      reporter: ['text', 'json', 'html'],
    },

    // Timeouts
    testTimeout: 5000,
    hookTimeout: 10000,

    // Parallelization
    fileParallelism: true,
    maxWorkers: '50%',
    maxConcurrency: 5,

    // Retries
    retry: 0,

    // Setup files
    setupFiles: ['./tests/setup.ts'],

    // Watch mode
    watch: true,
    watchExclude: ['**/node_modules/**', '**/dist/**'],
  },
})
```

### Shared Vite Configuration

Vitest can share configuration with Vite:

```typescript
import { defineConfig } from 'vitest/config'

export default defineConfig({
  // Vite options
  resolve: {
    alias: {
      '@': '/src',
    },
  },
  // Vitest options
  test: {
    environment: 'jsdom',
  },
})
```

### Key Configuration Options

| Option | Description | Default |
|--------|-------------|---------|
| `include` | Glob patterns for test files | `['**/*.{test,spec}.{js,ts,...}']` |
| `exclude` | Patterns to exclude | `['**/node_modules/**']` |
| `environment` | Test environment | `'node'` |
| `globals` | Enable global test APIs | `false` |
| `testTimeout` | Test timeout in ms | `5000` |
| `hookTimeout` | Hook timeout in ms | `10000` |
| `retry` | Retry failed tests | `0` |
| `maxWorkers` | Parallel workers | `50%` of CPU cores |
| `maxConcurrency` | Concurrent tests per file | `5` |
| `clearMocks` | Clear mocks between tests | `false` |
| `restoreMocks` | Restore mocks after each test | `false` |

### Global Setup

For one-time setup before all tests:

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    globalSetup: './tests/global-setup.ts',
  },
})

// tests/global-setup.ts
export default async function setup() {
  // Start database, seed data, etc.
  console.log('Global setup running...')

  // Return teardown function
  return async () => {
    console.log('Global teardown running...')
  }
}
```

---

## Writing Tests

### Basic Test Structure

```typescript
import { describe, it, expect, test } from 'vitest'

// Simple test
test('adds 1 + 2 to equal 3', () => {
  expect(1 + 2).toBe(3)
})

// Alias: it === test
it('subtracts 5 - 3 to equal 2', () => {
  expect(5 - 3).toBe(2)
})

// Async test
test('fetches data', async () => {
  const data = await fetchData()
  expect(data).toBeDefined()
})
```

### Test Grouping with `describe`

```typescript
import { describe, it, expect, beforeEach, afterEach } from 'vitest'

describe('Calculator', () => {
  let calculator: Calculator

  beforeEach(() => {
    calculator = new Calculator()
  })

  afterEach(() => {
    calculator.reset()
  })

  describe('addition', () => {
    it('adds positive numbers', () => {
      expect(calculator.add(2, 3)).toBe(5)
    })

    it('adds negative numbers', () => {
      expect(calculator.add(-2, -3)).toBe(-5)
    })
  })

  describe('division', () => {
    it('divides numbers', () => {
      expect(calculator.divide(10, 2)).toBe(5)
    })

    it('throws on division by zero', () => {
      expect(() => calculator.divide(10, 0)).toThrow('Division by zero')
    })
  })
})
```

### Lifecycle Hooks

```typescript
import { beforeAll, afterAll, beforeEach, afterEach } from 'vitest'

beforeAll(async () => {
  // Runs once before all tests in file
  await database.connect()
})

afterAll(async () => {
  // Runs once after all tests in file
  await database.disconnect()
})

beforeEach(() => {
  // Runs before each test
  resetState()
})

afterEach(() => {
  // Runs after each test
  cleanupResources()
})
```

### Skipping and Focusing Tests

```typescript
// Skip tests
test.skip('skipped test', () => {
  // This won't run
})

describe.skip('skipped suite', () => {
  // All tests in this suite are skipped
})

// Run only specific tests
test.only('only this runs', () => {
  // Other tests are skipped
})

describe.only('only this suite', () => {
  // Only tests in this suite run
})

// Conditional skipping
test.skipIf(process.env.CI)('skipped in CI', () => {
  // Skipped when CI environment variable is set
})

test.runIf(process.env.CI)('only in CI', () => {
  // Only runs in CI
})

// Todo placeholder
test.todo('implement this later')
```

### Parameterized Tests

```typescript
// test.each with array
test.each([
  [1, 1, 2],
  [1, 2, 3],
  [2, 2, 4],
])('adds %i + %i to equal %i', (a, b, expected) => {
  expect(a + b).toBe(expected)
})

// test.each with objects
test.each([
  { a: 1, b: 1, expected: 2 },
  { a: 1, b: 2, expected: 3 },
  { a: 2, b: 2, expected: 4 },
])('adds $a + $b to equal $expected', ({ a, b, expected }) => {
  expect(a + b).toBe(expected)
})

// test.for (Vitest 2+) - provides TestContext
test.for([
  { name: 'a', value: 1 },
  { name: 'b', value: 2 },
])('test $name', ({ name, value }, { expect }) => {
  expect(value).toBeGreaterThan(0)
})

// describe.each for parameterized suites
describe.each([
  { name: 'Chrome', version: '120' },
  { name: 'Firefox', version: '121' },
])('Browser: $name', ({ name, version }) => {
  test('has correct version', () => {
    expect(version).toBeDefined()
  })
})
```

### Concurrent Tests

```typescript
// Run tests concurrently within a file
test.concurrent('test 1', async () => {
  await sleep(100)
  expect(true).toBe(true)
})

test.concurrent('test 2', async () => {
  await sleep(100)
  expect(true).toBe(true)
})

// Concurrent suite
describe.concurrent('concurrent suite', () => {
  test('runs in parallel', async ({ expect }) => {
    // Use expect from context for snapshots in concurrent tests
    expect(1).toBe(1)
  })
})

// Sequential within concurrent suite
describe.concurrent('mixed', () => {
  test.sequential('must run first', async () => {})
  test.sequential('must run second', async () => {})
})
```

### Test Timeouts

```typescript
// Per-test timeout
test('slow test', async () => {
  await longOperation()
}, 10000) // 10 second timeout

// Or via options object
test('slow test', async () => {
  await longOperation()
}, { timeout: 10000 })

// Dynamic timeout
import { vi } from 'vitest'

beforeAll(() => {
  vi.setConfig({ testTimeout: 20000 })
})
```

### Running Tests

```bash
# Run all tests
npx vitest

# Run in watch mode (default in dev)
npx vitest watch

# Single run (no watch)
npx vitest run

# Run specific file
npx vitest run tests/unit/utils.test.ts

# Run tests matching pattern
npx vitest -t "should calculate"

# Run tests containing string in path
npx vitest basic

# Run test at specific line
npx vitest basic/foo.test.ts:10

# Run with UI
npx vitest --ui

# Run with coverage
npx vitest run --coverage
```

---

## Assertions

Vitest uses Chai assertions with Jest-compatible `expect` API.

### Basic Matchers

```typescript
// Equality
expect(2 + 2).toBe(4)                    // Strict equality (===)
expect({ a: 1 }).toEqual({ a: 1 })       // Deep equality
expect({ a: 1, b: undefined }).toStrictEqual({ a: 1 }) // Fails - checks undefined keys

// Truthiness
expect(value).toBeTruthy()
expect(value).toBeFalsy()
expect(value).toBeNull()
expect(value).toBeDefined()
expect(value).toBeUndefined()
expect(value).toBeNaN()

// Type checking
expect('hello').toBeTypeOf('string')
expect(new Date()).toBeInstanceOf(Date)
```

### Numeric Matchers

```typescript
expect(value).toBeGreaterThan(3)
expect(value).toBeGreaterThanOrEqual(3)
expect(value).toBeLessThan(5)
expect(value).toBeLessThanOrEqual(5)

// Floating point
expect(0.1 + 0.2).toBeCloseTo(0.3, 5)  // 5 decimal precision
```

### String Matchers

```typescript
expect('hello world').toMatch(/world/)
expect('hello world').toMatch('world')
expect('hello world').toContain('world')
expect('hello').toHaveLength(5)
```

### Array and Object Matchers

```typescript
// Arrays
expect([1, 2, 3]).toContain(2)
expect([{ a: 1 }, { a: 2 }]).toContainEqual({ a: 1 })
expect(['a', 'b', 'c']).toHaveLength(3)

// Objects
expect({ a: 1, b: 2 }).toHaveProperty('a')
expect({ a: 1, b: 2 }).toHaveProperty('a', 1)
expect({ nested: { value: 42 } }).toHaveProperty('nested.value', 42)
expect({ a: 1, b: 2 }).toMatchObject({ a: 1 })

// One of
expect('apple').toBeOneOf(['apple', 'banana', 'orange'])
```

### Error Matchers

```typescript
// Function throws
expect(() => {
  throw new Error('Something went wrong')
}).toThrow()

expect(() => {
  throw new Error('Something went wrong')
}).toThrow('Something went wrong')

expect(() => {
  throw new Error('Something went wrong')
}).toThrow(/wrong/)

expect(() => {
  throw new TypeError('Invalid type')
}).toThrow(TypeError)

// Async throws
await expect(asyncFn()).rejects.toThrow('error')
```

### Promise Matchers

```typescript
// Resolves
await expect(Promise.resolve(42)).resolves.toBe(42)
await expect(fetchData()).resolves.toEqual({ id: 1 })

// Rejects
await expect(Promise.reject('error')).rejects.toBe('error')
await expect(failingFn()).rejects.toThrow('Something failed')
```

### Mock Matchers

```typescript
const mockFn = vi.fn()
mockFn('arg1', 'arg2')
mockFn('arg3')

expect(mockFn).toHaveBeenCalled()
expect(mockFn).toHaveBeenCalledTimes(2)
expect(mockFn).toHaveBeenCalledWith('arg1', 'arg2')
expect(mockFn).toHaveBeenLastCalledWith('arg3')
expect(mockFn).toHaveBeenNthCalledWith(1, 'arg1', 'arg2')

// Return values
const getValue = vi.fn().mockReturnValue(42)
getValue()
expect(getValue).toHaveReturned()
expect(getValue).toHaveReturnedWith(42)
expect(getValue).toHaveReturnedTimes(1)

// Call order
expect(mock1).toHaveBeenCalledBefore(mock2)
expect(mock2).toHaveBeenCalledAfter(mock1)
```

### Negation

```typescript
expect(value).not.toBe(5)
expect(value).not.toEqual({ a: 1 })
expect(array).not.toContain('missing')
```

### Asymmetric Matchers

```typescript
expect({ name: 'John', age: 30 }).toEqual({
  name: expect.any(String),
  age: expect.any(Number),
})

expect(data).toEqual({
  id: expect.anything(),  // any value except null/undefined
  items: expect.arrayContaining([1, 2]),
  meta: expect.objectContaining({ type: 'user' }),
  description: expect.stringContaining('hello'),
  title: expect.stringMatching(/^Title:/),
})

// Negation
expect(data).toEqual({
  items: expect.not.arrayContaining([999]),
})
```

### Custom Matchers

```typescript
expect.extend({
  toBeWithinRange(received, floor, ceiling) {
    const pass = received >= floor && received <= ceiling
    return {
      pass,
      message: () =>
        pass
          ? `expected ${received} not to be within range ${floor} - ${ceiling}`
          : `expected ${received} to be within range ${floor} - ${ceiling}`,
    }
  },
})

// Usage
expect(100).toBeWithinRange(90, 110)

// TypeScript declaration
declare module 'vitest' {
  interface Assertion<T = any> {
    toBeWithinRange(floor: number, ceiling: number): T
  }
}
```

### Soft Assertions

Continue test execution after failed assertions:

```typescript
test('multiple checks', () => {
  expect.soft(1 + 1).toBe(3)  // Fails but continues
  expect.soft(2 + 2).toBe(5)  // Also fails but continues
  expect.soft(3 + 3).toBe(6)  // Passes

  // Test reports all failures at end
})
```

### Polling Assertions

Retry assertions until they pass:

```typescript
// Poll until truthy
await expect.poll(() => fetchStatus()).toBe('ready')

// With options
await expect.poll(
  async () => {
    const response = await fetch('/api/status')
    return response.status
  },
  {
    timeout: 10000,
    interval: 500,
  }
).toBe(200)
```

### Assertion Counting

```typescript
test('ensures all assertions run', () => {
  expect.assertions(2)

  expect(add(1, 2)).toBe(3)
  expect(subtract(5, 3)).toBe(2)
})

test('ensures at least one assertion', async () => {
  expect.hasAssertions()

  const data = await fetchData()
  if (data) {
    expect(data.id).toBeDefined()
  }
})
```

---

## Mocking

### Mock Functions

```typescript
import { vi, expect, test } from 'vitest'

// Create mock function
const mockFn = vi.fn()
mockFn('hello')
expect(mockFn).toHaveBeenCalledWith('hello')

// Mock with implementation
const mockAdd = vi.fn((a, b) => a + b)
expect(mockAdd(1, 2)).toBe(3)

// Mock return values
const mockGet = vi.fn()
  .mockReturnValue('default')
  .mockReturnValueOnce('first')
  .mockReturnValueOnce('second')

expect(mockGet()).toBe('first')
expect(mockGet()).toBe('second')
expect(mockGet()).toBe('default')

// Mock resolved values (async)
const mockFetch = vi.fn()
  .mockResolvedValue({ data: 'success' })
  .mockResolvedValueOnce({ data: 'first' })

await expect(mockFetch()).resolves.toEqual({ data: 'first' })

// Mock rejected values
const mockFail = vi.fn().mockRejectedValue(new Error('Failed'))
await expect(mockFail()).rejects.toThrow('Failed')
```

### Spying on Methods

```typescript
import { vi, expect, test } from 'vitest'

const cart = {
  items: [],
  addItem(item) {
    this.items.push(item)
    return this.items.length
  },
}

// Spy on method
const spy = vi.spyOn(cart, 'addItem')

cart.addItem('apple')
expect(spy).toHaveBeenCalledWith('apple')
expect(spy).toHaveReturnedWith(1)

// Spy and mock implementation
vi.spyOn(cart, 'addItem').mockImplementation(() => 999)
expect(cart.addItem('banana')).toBe(999)

// Spy on getter/setter
const obj = {
  _value: 0,
  get value() { return this._value },
  set value(v) { this._value = v },
}

vi.spyOn(obj, 'value', 'get').mockReturnValue(42)
expect(obj.value).toBe(42)
```

### Module Mocking

```typescript
import { vi, expect, test } from 'vitest'

// Mock entire module (hoisted to top of file)
vi.mock('./api', () => ({
  fetchUser: vi.fn().mockResolvedValue({ id: 1, name: 'John' }),
  fetchPosts: vi.fn().mockResolvedValue([]),
}))

// Import after mock declaration
import { fetchUser, fetchPosts } from './api'

test('uses mocked module', async () => {
  const user = await fetchUser(1)
  expect(user.name).toBe('John')
})

// Partial mock - keep some original implementations
vi.mock('./utils', async (importOriginal) => {
  const actual = await importOriginal()
  return {
    ...actual,
    formatDate: vi.fn().mockReturnValue('2024-01-01'),
  }
})

// Dynamic mock (not hoisted)
vi.doMock('./config', () => ({
  default: { env: 'test' },
}))

// Import actual implementation
const actualModule = await vi.importActual('./api')

// Unmock
vi.unmock('./api')
```

### Mocking Classes

```typescript
import { vi } from 'vitest'

vi.mock('./database', () => {
  const MockDatabase = vi.fn(() => ({
    connect: vi.fn().mockResolvedValue(true),
    query: vi.fn().mockResolvedValue([]),
    close: vi.fn(),
  }))
  return { Database: MockDatabase }
})

import { Database } from './database'

test('uses mocked class', async () => {
  const db = new Database()
  await db.connect()
  expect(db.connect).toHaveBeenCalled()
})
```

### Timer Mocking

```typescript
import { vi, beforeEach, afterEach, test, expect } from 'vitest'

beforeEach(() => {
  vi.useFakeTimers()
})

afterEach(() => {
  vi.useRealTimers()
})

test('handles setTimeout', () => {
  const callback = vi.fn()
  setTimeout(callback, 1000)

  expect(callback).not.toHaveBeenCalled()

  vi.advanceTimersByTime(1000)
  expect(callback).toHaveBeenCalledTimes(1)
})

test('handles setInterval', () => {
  const callback = vi.fn()
  setInterval(callback, 100)

  vi.advanceTimersByTime(350)
  expect(callback).toHaveBeenCalledTimes(3)
})

test('runs all timers', () => {
  const callback = vi.fn()
  setTimeout(callback, 1000)
  setTimeout(callback, 2000)

  vi.runAllTimers()
  expect(callback).toHaveBeenCalledTimes(2)
})

test('runs only pending timers', () => {
  const outer = vi.fn(() => {
    setTimeout(inner, 1000)
  })
  const inner = vi.fn()

  setTimeout(outer, 1000)

  vi.runOnlyPendingTimers()
  expect(outer).toHaveBeenCalled()
  expect(inner).not.toHaveBeenCalled()
})
```

### Date Mocking

```typescript
import { vi, beforeEach, afterEach, test, expect } from 'vitest'

beforeEach(() => {
  vi.useFakeTimers()
})

afterEach(() => {
  vi.useRealTimers()
})

test('mocks current date', () => {
  vi.setSystemTime(new Date('2024-01-15'))

  expect(new Date().toISOString()).toBe('2024-01-15T00:00:00.000Z')
  expect(Date.now()).toBe(new Date('2024-01-15').getTime())
})

test('advances time', () => {
  vi.setSystemTime(new Date('2024-01-15'))

  vi.advanceTimersByTime(24 * 60 * 60 * 1000) // 1 day

  expect(new Date().toISOString()).toBe('2024-01-16T00:00:00.000Z')
})
```

### Global Mocking

```typescript
import { vi, beforeEach, afterEach, test, expect } from 'vitest'

// Mock global variable
vi.stubGlobal('navigator', {
  userAgent: 'vitest-agent',
})

test('uses mocked global', () => {
  expect(navigator.userAgent).toBe('vitest-agent')
})

// Mock environment variables
vi.stubEnv('API_URL', 'http://test.api.com')

test('uses mocked env', () => {
  expect(import.meta.env.API_URL).toBe('http://test.api.com')
})

// Restore all
afterEach(() => {
  vi.unstubAllGlobals()
  vi.unstubAllEnvs()
})
```

### Mock Cleanup

```typescript
import { vi, beforeEach, afterEach } from 'vitest'

// Configure automatic cleanup in vitest.config.ts
// test: { clearMocks: true, restoreMocks: true }

// Or manually
afterEach(() => {
  vi.clearAllMocks()   // Clear call history
  vi.resetAllMocks()   // Clear history + reset implementations
  vi.restoreAllMocks() // Restore original implementations (spyOn only)
})

// Per-mock cleanup
const mockFn = vi.fn()
mockFn.mockClear()    // Clear call history
mockFn.mockReset()    // Clear history + reset implementation
mockFn.mockRestore()  // Restore original (if created with spyOn)
```

---

## Snapshots

### Basic Snapshots

```typescript
import { test, expect } from 'vitest'

test('matches snapshot', () => {
  const user = {
    id: 1,
    name: 'John',
    email: 'john@example.com',
  }

  expect(user).toMatchSnapshot()
})

// First run creates: __snapshots__/example.test.ts.snap
// Subsequent runs compare against stored snapshot
```

### Inline Snapshots

```typescript
test('matches inline snapshot', () => {
  const result = formatUser({ id: 1, name: 'John' })

  // First run: Vitest fills in the snapshot
  expect(result).toMatchInlineSnapshot(`
    {
      "displayName": "John",
      "id": 1,
    }
  `)
})
```

### File Snapshots

```typescript
test('matches file snapshot', async () => {
  const html = renderComponent()

  await expect(html).toMatchFileSnapshot('./snapshots/component.html')
})
```

### Snapshot with Asymmetric Matchers

```typescript
test('snapshot with dynamic values', () => {
  const user = {
    id: 123,
    name: 'John',
    createdAt: new Date(),
  }

  expect(user).toMatchSnapshot({
    id: expect.any(Number),
    createdAt: expect.any(Date),
  })
})
```

### Custom Serializers

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    snapshotSerializers: ['./tests/serializers/custom.ts'],
  },
})

// tests/serializers/custom.ts
export default {
  test(value) {
    return value instanceof MyClass
  },
  serialize(value, config, indentation, depth, refs, printer) {
    return `MyClass { value: ${value.value} }`
  },
}

// Or inline
expect.addSnapshotSerializer({
  test: (val) => val instanceof Date,
  serialize: (val) => `Date: ${val.toISOString()}`,
})
```

### Updating Snapshots

```bash
# Update all snapshots
npx vitest -u

# Update in watch mode (press 'u')
npx vitest

# Update specific file
npx vitest -u tests/component.test.ts
```

### Snapshot Configuration

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    snapshotFormat: {
      printBasicPrototype: false,
      escapeString: false,
    },
    resolveSnapshotPath: (testPath, snapExtension) => {
      return testPath.replace('tests', '__snapshots__') + snapExtension
    },
  },
})
```

---

## Test Context & Fixtures

### Built-in Context

```typescript
import { test } from 'vitest'

test('has access to context', ({ expect, task, skip }) => {
  // expect - bound to current test (important for concurrent tests)
  expect(1 + 1).toBe(2)

  // task - test metadata
  console.log(task.name) // test name

  // skip - skip test dynamically
  if (someCondition) {
    skip('Skipping due to condition')
  }
})
```

### Extending Test Context with Fixtures

```typescript
import { test as base } from 'vitest'

// Define fixture types
interface MyFixtures {
  database: Database
  authenticatedUser: User
}

// Extend test with fixtures
export const test = base.extend<MyFixtures>({
  // Simple fixture
  database: async ({}, use) => {
    const db = await Database.connect()
    await use(db)
    await db.disconnect()
  },

  // Fixture with dependencies
  authenticatedUser: async ({ database }, use) => {
    const user = await database.createUser({ name: 'Test User' })
    await use(user)
    await database.deleteUser(user.id)
  },
})

// Use in tests
test('creates post for user', async ({ database, authenticatedUser }) => {
  const post = await database.createPost({
    userId: authenticatedUser.id,
    title: 'Test Post',
  })

  expect(post.userId).toBe(authenticatedUser.id)
})
```

### Automatic Fixtures

```typescript
export const test = base.extend({
  // Auto fixture runs for every test
  analytics: [async ({}, use) => {
    await analytics.init()
    await use()
    await analytics.flush()
  }, { auto: true }],
})
```

### Scoped Fixtures

```typescript
export const test = base.extend({
  // File-scoped - shared across all tests in file
  sharedResource: [async ({}, use) => {
    const resource = await createExpensiveResource()
    await use(resource)
    await resource.cleanup()
  }, { scope: 'file' }],

  // Worker-scoped - shared across all tests in worker
  workerResource: [async ({}, use) => {
    const resource = await createResource()
    await use(resource)
  }, { scope: 'worker' }],
})
```

### Fixture Options

```typescript
interface Options {
  baseUrl: string
}

export const test = base.extend<{}, Options>({
  baseUrl: ['http://localhost:3000', { option: true }],
})

// Override in config
export default defineConfig({
  test: {
    provide: {
      baseUrl: 'http://staging.example.com',
    },
  },
})
```

### Scoped Context Values

```typescript
import { test } from './fixtures'

test.scoped({ locale: 'fr' })

describe('French tests', () => {
  test('uses French locale', ({ locale }) => {
    expect(locale).toBe('fr')
  })
})
```

---

## Code Coverage

### Setup

```bash
# Install coverage provider
npm install -D @vitest/coverage-v8
# or
npm install -D @vitest/coverage-istanbul
```

### Configuration

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    coverage: {
      // Provider
      provider: 'v8', // or 'istanbul'

      // Enable
      enabled: true,

      // Files to include/exclude
      include: ['src/**/*.{ts,tsx}'],
      exclude: [
        'node_modules/',
        'src/**/*.test.ts',
        'src/**/*.d.ts',
      ],

      // Reporters
      reporter: ['text', 'json', 'html', 'lcov'],

      // Output directory
      reportsDirectory: './coverage',

      // Thresholds
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 80,
        statements: 80,
      },

      // Fail if thresholds not met
      thresholds: {
        lines: 80,
        perFile: true,    // Check per file
        autoUpdate: true, // Update thresholds in config
      },

      // All files (not just tested)
      all: true,

      // Clean before running
      clean: true,
    },
  },
})
```

### Running Coverage

```bash
# Run with coverage
npx vitest run --coverage

# Coverage in watch mode
npx vitest --coverage

# Specific coverage reporter
npx vitest run --coverage.reporter=text
```

### Ignoring Code

```typescript
// Ignore next line
/* v8 ignore next */
const devOnlyCode = process.env.DEV ? 'dev' : 'prod'

// Ignore next N lines
/* v8 ignore next 3 */
if (process.env.DEV) {
  console.log('dev mode')
}

// Ignore block
/* v8 ignore start */
function devOnlyFunction() {
  // Not counted in coverage
}
/* v8 ignore stop */

// Istanbul syntax also works
/* istanbul ignore next */
```

### Coverage Providers

**V8 (Recommended)**
- Native V8 coverage, no instrumentation needed
- Faster and lower memory usage
- Requires V8-based runtime (Node.js, Chrome)

**Istanbul**
- Works on any JavaScript runtime
- Pre-instrumentation via Babel
- Battle-tested, widely used

---

## Test Environments

### Built-in Environments

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    environment: 'node', // Default - Node.js environment
  },
})

// Other options:
// 'jsdom'       - Browser-like environment using jsdom
// 'happy-dom'   - Faster browser emulation
// 'edge-runtime' - Vercel Edge Runtime emulation
```

### Per-File Environment

```typescript
// @vitest-environment jsdom

import { test, expect } from 'vitest'

test('uses browser APIs', () => {
  document.body.innerHTML = '<div id="app">Hello</div>'
  expect(document.getElementById('app')?.textContent).toBe('Hello')
})
```

### Environment Options

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    environment: 'jsdom',
    environmentOptions: {
      jsdom: {
        url: 'http://localhost:3000',
        referrer: 'http://localhost:3000',
        resources: 'usable',
      },
    },
  },
})

// Per-file options
/**
 * @vitest-environment jsdom
 * @vitest-environment-options { "url": "http://localhost:3000" }
 */
```

### Custom Environment

```typescript
// vitest-environment-custom.ts
import type { Environment } from 'vitest/runtime'

export default <Environment>{
  name: 'custom',
  viteEnvironment: 'ssr',

  async setup(global, options) {
    // Setup global environment
    global.customProperty = 'value'

    return {
      async teardown() {
        // Cleanup
        delete global.customProperty
      },
    }
  },
}

// vitest.config.ts
export default defineConfig({
  test: {
    environment: './vitest-environment-custom.ts',
  },
})
```

---

## Type Testing

Vitest can test TypeScript types statically.

### Setup

```bash
# Add to package.json
{
  "scripts": {
    "test:types": "vitest typecheck"
  }
}
```

### Configuration

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    typecheck: {
      enabled: true,
      include: ['**/*.test-d.ts'],
      tsconfig: './tsconfig.json',
    },
  },
})
```

### Writing Type Tests

```typescript
// utils.test-d.ts
import { expectTypeOf, assertType } from 'vitest'
import { add, User, createUser } from './utils'

test('add returns number', () => {
  expectTypeOf(add(1, 2)).toBeNumber()
  expectTypeOf(add).parameter(0).toBeNumber()
  expectTypeOf(add).returns.toBeNumber()
})

test('User type structure', () => {
  expectTypeOf<User>().toMatchTypeOf<{ id: number; name: string }>()
  expectTypeOf<User>().toHaveProperty('id')
})

test('createUser function', () => {
  expectTypeOf(createUser).toBeFunction()
  expectTypeOf(createUser).parameter(0).toMatchTypeOf<{ name: string }>()
  expectTypeOf(createUser).returns.toMatchTypeOf<User>()
})

// Assert specific type
test('assertType usage', () => {
  const result = createUser({ name: 'John' })
  assertType<User>(result)
})

// Negative assertions with ts-expect-error
test('rejects invalid types', () => {
  // @ts-expect-error - should not accept string
  add('a', 'b')
})
```

### expectTypeOf Matchers

```typescript
expectTypeOf<T>().toBeString()
expectTypeOf<T>().toBeNumber()
expectTypeOf<T>().toBeBoolean()
expectTypeOf<T>().toBeVoid()
expectTypeOf<T>().toBeNull()
expectTypeOf<T>().toBeUndefined()
expectTypeOf<T>().toBeNullable()
expectTypeOf<T>().toBeFunction()
expectTypeOf<T>().toBeObject()
expectTypeOf<T>().toBeArray()
expectTypeOf<T>().toBeNever()
expectTypeOf<T>().toBeAny()
expectTypeOf<T>().toBeUnknown()

expectTypeOf<T>().toEqualTypeOf<U>()      // Exact match
expectTypeOf<T>().toMatchTypeOf<U>()      // T extends U
expectTypeOf<T>().toHaveProperty('key')

expectTypeOf<Fn>().parameter(0).toBeString()
expectTypeOf<Fn>().parameters.toEqualTypeOf<[string, number]>()
expectTypeOf<Fn>().returns.toBeNumber()

// Negation
expectTypeOf<T>().not.toBeString()
```

---

## Projects & Workspaces

### Multi-Project Configuration

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    projects: [
      'packages/*',           // All packages
      '!packages/legacy',     // Exclude legacy
      {
        // Inline project
        extends: true,
        test: {
          name: 'unit',
          include: ['tests/unit/**/*.test.ts'],
        },
      },
      {
        extends: true,
        test: {
          name: 'integration',
          include: ['tests/integration/**/*.test.ts'],
          environment: 'jsdom',
        },
      },
    ],
  },
})
```

### Project-Specific Config

```typescript
// packages/web/vitest.config.ts
import { defineProject } from 'vitest/config'

export default defineProject({
  test: {
    name: 'web',
    environment: 'jsdom',
    setupFiles: ['./tests/setup.ts'],
  },
})
```

### Running Specific Projects

```bash
# Run specific project
npx vitest --project unit

# Run multiple projects
npx vitest --project unit --project integration

# Run all projects
npx vitest
```

### Shared Configuration

```typescript
// vitest.shared.ts
export const sharedConfig = {
  testTimeout: 10000,
  hookTimeout: 10000,
}

// packages/web/vitest.config.ts
import { defineProject, mergeConfig } from 'vitest/config'
import { sharedConfig } from '../../vitest.shared'

export default defineProject(mergeConfig(sharedConfig, {
  test: {
    name: 'web',
    environment: 'jsdom',
  },
}))
```

---

## Reporters

### Built-in Reporters

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    reporters: ['default'], // Default reporter

    // Other options:
    // 'verbose'  - Prints each test individually
    // 'dot'      - Minimal dots for each test
    // 'json'     - JSON output
    // 'junit'    - JUnit XML format
    // 'tap'      - TAP format
    // 'tap-flat' - TAP flat format
    // 'html'     - HTML report (requires @vitest/ui)
    // 'hanging-process' - Detects hanging processes
    // 'github-actions' - GitHub Actions annotations
    // 'blob'     - For merging reports
  },
})
```

### Multiple Reporters

```typescript
export default defineConfig({
  test: {
    reporters: ['default', 'json', 'junit'],
    outputFile: {
      json: './reports/test-results.json',
      junit: './reports/junit.xml',
    },
  },
})
```

### Reporter Options

```typescript
export default defineConfig({
  test: {
    reporters: [
      ['junit', {
        suiteName: 'My Test Suite',
        classNameTemplate: '{filepath}',
        includeConsoleOutput: true,
      }],
      ['json', {
        outputFile: './reports/results.json',
      }],
    ],
  },
})
```

### Custom Reporter

```typescript
// custom-reporter.ts
import type { Reporter } from 'vitest/reporters'

export default class CustomReporter implements Reporter {
  onInit(ctx) {
    console.log('Tests starting...')
  }

  onFinished(files, errors) {
    const passed = files.flatMap(f => f.tasks).filter(t => t.result?.state === 'pass').length
    const failed = files.flatMap(f => f.tasks).filter(t => t.result?.state === 'fail').length
    console.log(`Results: ${passed} passed, ${failed} failed`)
  }

  onTaskUpdate(packs) {
    for (const [id, result] of packs) {
      if (result?.state === 'fail') {
        console.log(`FAILED: ${id}`)
      }
    }
  }
}

// vitest.config.ts
export default defineConfig({
  test: {
    reporters: ['./custom-reporter.ts'],
  },
})
```

### HTML Reporter (Vitest UI)

```bash
# Install
npm install -D @vitest/ui

# Run with UI
npx vitest --ui

# Generate HTML report
npx vitest run --reporter=html
```

---

## Debugging

### VS Code

**JavaScript Debug Terminal:**
1. Open Command Palette (Cmd/Ctrl + Shift + P)
2. Select "JavaScript Debug Terminal"
3. Run `npm test` or `npx vitest`

**Launch Configuration:**

```json
// .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Current Test File",
      "autoAttachChildProcesses": true,
      "skipFiles": ["<node_internals>/**", "**/node_modules/**"],
      "program": "${workspaceRoot}/node_modules/vitest/vitest.mjs",
      "args": ["run", "${relativeFile}"],
      "smartStep": true,
      "console": "integratedTerminal"
    },
    {
      "type": "node",
      "request": "launch",
      "name": "Debug All Tests",
      "autoAttachChildProcesses": true,
      "skipFiles": ["<node_internals>/**", "**/node_modules/**"],
      "program": "${workspaceRoot}/node_modules/vitest/vitest.mjs",
      "args": ["run"],
      "smartStep": true,
      "console": "integratedTerminal"
    }
  ]
}
```

### Node Inspector

```bash
# Start with inspector
npx vitest --inspect-brk --no-file-parallelism

# Open Chrome DevTools
# Navigate to chrome://inspect
# Click "inspect" on the Node process
```

### IntelliJ IDEA

1. Create new Run Configuration
2. Set type to "Vitest"
3. Set working directory to project root
4. Run in Debug mode

### Debugging Tips

```typescript
import { test, vi } from 'vitest'

test('debugging example', async () => {
  // Add breakpoint here
  debugger

  // Console logging
  console.log('Debug value:', value)

  // Disable timeouts during debugging
  vi.setConfig({ testTimeout: 0 })
})
```

### CLI Debug Options

```bash
# Disable timeouts (useful when paused at breakpoints)
npx vitest --test-timeout=0

# Disable parallelism (easier to debug)
npx vitest --no-file-parallelism

# Run single test
npx vitest -t "my test name"

# Verbose output
npx vitest --reporter=verbose
```

---

## Migration from Jest

### Configuration Changes

```typescript
// jest.config.js (before)
module.exports = {
  testEnvironment: 'jsdom',
  setupFilesAfterEnv: ['./jest.setup.js'],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
}

// vitest.config.ts (after)
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    environment: 'jsdom',
    setupFiles: ['./vitest.setup.ts'],
    globals: true, // Enable Jest-like globals
  },
  resolve: {
    alias: {
      '@': '/src',
    },
  },
})
```

### API Differences

```typescript
// Globals - must enable or import
import { describe, it, expect, vi } from 'vitest'

// jest.fn() → vi.fn()
const mockFn = vi.fn()

// jest.mock() → vi.mock()
vi.mock('./module')

// jest.spyOn() → vi.spyOn()
vi.spyOn(object, 'method')

// jest.useFakeTimers() → vi.useFakeTimers()
vi.useFakeTimers()

// jest.requireActual() → vi.importActual()
const actual = await vi.importActual('./module')

// jest.setTimeout() → vi.setConfig()
vi.setConfig({ testTimeout: 10000 })
```

### Mock Behavior Differences

```typescript
// Jest: mockReset replaces with empty function
// Vitest: mockReset restores original

// Jest: factory default export automatic
jest.mock('./mod', () => 'value')

// Vitest: must be explicit
vi.mock('./mod', () => ({ default: 'value' }))
```

### Environment Variables

```typescript
// Jest
process.env.JEST_WORKER_ID

// Vitest
process.env.VITEST_POOL_ID
process.env.VITEST_WORKER_ID
```

### Snapshot Path

```typescript
// Jest: uses space separator
// "describe title test title"

// Vitest: uses > separator
// "describe title > test title"
```

### Unsupported Features

- Legacy fake timers (`jest.useFakeTimers('legacy')`)
- Done callback (use async/await instead)
- `jest.replaceProperty()` (use `vi.spyOn()` or `vi.stubEnv()`)

---

## Best Practices

### 1. Use Descriptive Test Names

```typescript
// ✅ Good: Describes behavior and expectation
test('returns null when user is not found', () => {
  expect(findUser('nonexistent')).toBeNull()
})

// ❌ Bad: Vague description
test('findUser test', () => {
  expect(findUser('nonexistent')).toBeNull()
})
```

### 2. Follow AAA Pattern

```typescript
test('calculates total with discount', () => {
  // Arrange
  const cart = new Cart()
  cart.addItem({ price: 100 })
  cart.applyDiscount(0.1)

  // Act
  const total = cart.getTotal()

  // Assert
  expect(total).toBe(90)
})
```

### 3. Keep Tests Isolated

```typescript
// ✅ Good: Each test is independent
describe('UserService', () => {
  let service: UserService

  beforeEach(() => {
    service = new UserService()
  })

  test('creates user', () => {
    const user = service.create({ name: 'John' })
    expect(user.id).toBeDefined()
  })

  test('finds user', () => {
    const created = service.create({ name: 'Jane' })
    const found = service.find(created.id)
    expect(found.name).toBe('Jane')
  })
})
```

### 4. Mock External Dependencies

```typescript
// ✅ Good: Mock external services
vi.mock('./api', () => ({
  fetchUser: vi.fn().mockResolvedValue({ id: 1, name: 'Test' }),
}))

test('displays user name', async () => {
  const name = await getUserName(1)
  expect(name).toBe('Test')
})

// ❌ Bad: Testing against real external APIs
test('displays user name', async () => {
  const name = await getUserName(1) // Calls real API
  expect(name).toBeDefined()
})
```

### 5. Use Appropriate Assertions

```typescript
// ✅ Good: Specific assertions
expect(user).toEqual({ id: 1, name: 'John' })
expect(array).toHaveLength(3)
expect(fn).toHaveBeenCalledWith('arg')

// ❌ Bad: Vague assertions
expect(user).toBeTruthy()
expect(array.length > 0).toBe(true)
expect(fn.mock.calls.length).toBe(1)
```

### 6. Test Edge Cases

```typescript
describe('divide', () => {
  test('divides positive numbers', () => {
    expect(divide(10, 2)).toBe(5)
  })

  test('handles negative numbers', () => {
    expect(divide(-10, 2)).toBe(-5)
  })

  test('throws on division by zero', () => {
    expect(() => divide(10, 0)).toThrow()
  })

  test('handles decimal results', () => {
    expect(divide(10, 3)).toBeCloseTo(3.333, 3)
  })
})
```

### 7. Use Fixtures for Complex Setup

```typescript
// ✅ Good: Reusable fixtures
export const test = base.extend({
  authenticatedUser: async ({}, use) => {
    const user = await createTestUser()
    await login(user)
    await use(user)
    await deleteTestUser(user)
  },
})

test('can access dashboard', async ({ authenticatedUser }) => {
  const dashboard = await getDashboard(authenticatedUser.id)
  expect(dashboard).toBeDefined()
})
```

### 8. Clean Up After Tests

```typescript
afterEach(() => {
  vi.clearAllMocks()
  vi.useRealTimers()
  vi.unstubAllGlobals()
})

afterAll(async () => {
  await database.disconnect()
})
```

### 9. Use TypeScript

```typescript
// vitest.config.ts with type safety
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    // TypeScript catches config errors
  },
})

// Type-safe mocks
const mockFn = vi.fn<[string, number], boolean>()
```

### 10. Run Tests in CI

```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: npm ci
      - run: npm test -- --coverage
      - uses: codecov/codecov-action@v4
        with:
          files: ./coverage/lcov.info
```

---

## Quick Reference

### Common Commands

| Command | Description |
|---------|-------------|
| `npx vitest` | Run tests in watch mode |
| `npx vitest run` | Single run (no watch) |
| `npx vitest --ui` | Open Vitest UI |
| `npx vitest --coverage` | Run with coverage |
| `npx vitest -t "pattern"` | Run tests matching pattern |
| `npx vitest path/to/file` | Run specific file |
| `npx vitest -u` | Update snapshots |
| `npx vitest --reporter=verbose` | Verbose output |
| `npx vitest typecheck` | Run type tests |
| `npx vitest bench` | Run benchmarks |
| `npx vitest list` | List all tests |
| `npx vitest --project=name` | Run specific project |

### Assertion Cheat Sheet

| Assertion | Description |
|-----------|-------------|
| `toBe(value)` | Strict equality |
| `toEqual(value)` | Deep equality |
| `toStrictEqual(value)` | Strict deep equality |
| `toBeTruthy()` | Truthy value |
| `toBeFalsy()` | Falsy value |
| `toBeNull()` | Is null |
| `toBeDefined()` | Not undefined |
| `toBeUndefined()` | Is undefined |
| `toBeNaN()` | Is NaN |
| `toBeGreaterThan(n)` | > n |
| `toBeLessThan(n)` | < n |
| `toBeCloseTo(n, digits)` | Float comparison |
| `toContain(item)` | Array/string contains |
| `toHaveLength(n)` | Length check |
| `toHaveProperty(key)` | Object has key |
| `toMatch(regex)` | String matches |
| `toThrow(error?)` | Function throws |
| `toHaveBeenCalled()` | Mock was called |
| `toHaveBeenCalledWith(args)` | Mock called with args |
| `toMatchSnapshot()` | Matches snapshot |

### Mock Cheat Sheet

| Method | Description |
|--------|-------------|
| `vi.fn()` | Create mock function |
| `vi.spyOn(obj, 'method')` | Spy on method |
| `vi.mock('module')` | Mock module |
| `vi.mocked(fn)` | Type helper |
| `vi.importActual('module')` | Get actual module |
| `mockFn.mockReturnValue(val)` | Set return value |
| `mockFn.mockResolvedValue(val)` | Set async return |
| `mockFn.mockImplementation(fn)` | Set implementation |
| `mockFn.mockClear()` | Clear call history |
| `mockFn.mockReset()` | Reset mock |
| `mockFn.mockRestore()` | Restore original |
| `vi.clearAllMocks()` | Clear all mocks |
| `vi.resetAllMocks()` | Reset all mocks |
| `vi.restoreAllMocks()` | Restore all mocks |

### Timer Cheat Sheet

| Method | Description |
|--------|-------------|
| `vi.useFakeTimers()` | Enable fake timers |
| `vi.useRealTimers()` | Restore real timers |
| `vi.setSystemTime(date)` | Set mock date |
| `vi.advanceTimersByTime(ms)` | Advance time |
| `vi.runAllTimers()` | Run all timers |
| `vi.runOnlyPendingTimers()` | Run pending only |
| `vi.getTimerCount()` | Get pending count |
| `vi.clearAllTimers()` | Clear all timers |
