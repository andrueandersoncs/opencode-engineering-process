# Playwright Testing Guide

A comprehensive guide to writing robust, maintainable end-to-end tests with Playwright.

## Table of Contents

1. [Installation & Setup](#installation--setup)
2. [Project Structure](#project-structure)
3. [Configuration](#configuration)
4. [Writing Tests](#writing-tests)
5. [Locators](#locators)
6. [Assertions](#assertions)
7. [Page Object Models](#page-object-models)
8. [Fixtures](#fixtures)
9. [Mocking & Network Interception](#mocking--network-interception)
10. [API Testing](#api-testing)
11. [Test Retries & Parallelization](#test-retries--parallelization)
12. [Debugging](#debugging)
13. [Best Practices](#best-practices)

---

## Installation & Setup

### Quick Start

```bash
# Using npm
npm init playwright@latest

# Using yarn
yarn create playwright

# Using pnpm
pnpm create playwright
```

During setup, you'll configure:
- Language preference (TypeScript or JavaScript)
- Test folder location
- GitHub Actions workflow integration
- Browser installation

### System Requirements

- **Node.js**: 20.x, 22.x, or 24.x
- **Windows**: 11+, Windows Server 2019+, or WSL
- **macOS**: 14 (Ventura) or later
- **Linux**: Debian 12/13 or Ubuntu 22.04/24.04

### Updating Playwright

```bash
npm install -D @playwright/test@latest
npx playwright install --with-deps
```

---

## Project Structure

After installation, Playwright creates:

```
├── playwright.config.ts    # Central configuration file
├── package.json            # Project dependencies
├── tests/
│   └── example.spec.ts     # Test files
└── test-results/           # Test artifacts (screenshots, traces)
```

---

## Configuration

### Basic Configuration (`playwright.config.ts`)

```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  // Test directory
  testDir: './tests',

  // Run all tests in parallel
  fullyParallel: true,

  // Fail CI if test.only is left in code
  forbidOnly: !!process.env.CI,

  // Retry failed tests
  retries: process.env.CI ? 2 : 0,

  // Parallel workers
  workers: process.env.CI ? 1 : undefined,

  // Reporter configuration
  reporter: 'html',

  // Shared settings for all projects
  use: {
    // Base URL for navigation
    baseURL: 'http://localhost:3000',

    // Collect trace on first retry
    trace: 'on-first-retry',

    // Screenshot on failure
    screenshot: 'only-on-failure',
  },

  // Browser projects
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
    // Mobile viewports
    {
      name: 'Mobile Chrome',
      use: { ...devices['Pixel 5'] },
    },
    {
      name: 'Mobile Safari',
      use: { ...devices['iPhone 12'] },
    },
  ],

  // Run local dev server before tests
  webServer: {
    command: 'npm run start',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

### Key Configuration Options

| Option | Description | Default |
|--------|-------------|---------|
| `testDir` | Directory containing test files | `./tests` |
| `testMatch` | Glob pattern for test files | `**/*.@(spec\|test).?(c\|m)[jt]s?(x)` |
| `timeout` | Test timeout in milliseconds | `30000` |
| `expect.timeout` | Assertion timeout | `5000` |
| `retries` | Number of retry attempts | `0` |
| `workers` | Number of parallel workers | `50%` of CPU cores |
| `outputDir` | Directory for test artifacts | `test-results` |

### Expect Configuration

```typescript
expect: {
  timeout: 5000,
  toHaveScreenshot: {
    maxDiffPixels: 100,
  },
  toMatchSnapshot: {
    maxDiffPixelRatio: 0.1,
  },
},
```

---

## Writing Tests

### Basic Test Structure

```typescript
import { test, expect } from '@playwright/test';

test('has title', async ({ page }) => {
  await page.goto('https://example.com');
  await expect(page).toHaveTitle(/Example/);
});

test('navigation works', async ({ page }) => {
  await page.goto('https://example.com');
  await page.getByRole('link', { name: 'About' }).click();
  await expect(page).toHaveURL(/.*about/);
});
```

### Test Grouping with `describe`

```typescript
import { test, expect } from '@playwright/test';

test.describe('Authentication', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/login');
  });

  test('successful login', async ({ page }) => {
    await page.getByLabel('Email').fill('user@example.com');
    await page.getByLabel('Password').fill('password123');
    await page.getByRole('button', { name: 'Sign in' }).click();
    await expect(page).toHaveURL('/dashboard');
  });

  test('failed login shows error', async ({ page }) => {
    await page.getByLabel('Email').fill('wrong@example.com');
    await page.getByLabel('Password').fill('wrongpassword');
    await page.getByRole('button', { name: 'Sign in' }).click();
    await expect(page.getByText('Invalid credentials')).toBeVisible();
  });
});
```

### Hooks

```typescript
test.beforeAll(async () => {
  // Runs once before all tests in the file
  // Good for database seeding
});

test.afterAll(async () => {
  // Runs once after all tests in the file
  // Good for cleanup
});

test.beforeEach(async ({ page }) => {
  // Runs before each test
  await page.goto('/');
});

test.afterEach(async ({ page }) => {
  // Runs after each test
});
```

### Running Tests

```bash
# Run all tests
npx playwright test

# Run specific test file
npx playwright test tests/login.spec.ts

# Run tests with specific title
npx playwright test -g "login"

# Run in headed mode (see browser)
npx playwright test --headed

# Run specific project/browser
npx playwright test --project=chromium

# Run in UI mode (interactive)
npx playwright test --ui

# Run in debug mode
npx playwright test --debug
```

---

## Locators

Locators are the core mechanism for finding elements on the page. They have built-in auto-waiting and retry-ability.

### Recommended Locators (Priority Order)

#### 1. `getByRole()` - Accessibility-Based (Preferred)

The most resilient locator type. Reflects how users and assistive technology perceive the page.

```typescript
// Buttons
await page.getByRole('button', { name: 'Submit' }).click();

// Links
await page.getByRole('link', { name: 'Learn more' }).click();

// Headings
await expect(page.getByRole('heading', { name: 'Welcome' })).toBeVisible();

// Form elements
await page.getByRole('textbox', { name: 'Email' }).fill('test@example.com');
await page.getByRole('checkbox', { name: 'Remember me' }).check();

// Navigation
await page.getByRole('navigation').getByRole('link', { name: 'Home' }).click();

// Lists
const items = page.getByRole('listitem');
```

Common roles: `button`, `link`, `heading`, `textbox`, `checkbox`, `radio`, `combobox`, `listitem`, `navigation`, `main`, `dialog`, `alert`.

#### 2. `getByLabel()` - Form Controls

Locates form elements by their associated label text.

```typescript
await page.getByLabel('Username').fill('john_doe');
await page.getByLabel('Password').fill('secret123');
await page.getByLabel('Remember me').check();
```

#### 3. `getByPlaceholder()` - Input Placeholders

```typescript
await page.getByPlaceholder('Search...').fill('query');
await page.getByPlaceholder('Enter your email').fill('test@example.com');
```

#### 4. `getByText()` - Text Content

Matches elements containing the specified text.

```typescript
// Substring match (default)
await page.getByText('Welcome').click();

// Exact match
await page.getByText('Welcome back!', { exact: true }).click();

// Regex match
await page.getByText(/welcome/i).click();
```

#### 5. `getByAltText()` - Images

```typescript
await page.getByAltText('Company Logo').click();
await expect(page.getByAltText('Profile picture')).toBeVisible();
```

#### 6. `getByTitle()` - Title Attribute

```typescript
await page.getByTitle('Close dialog').click();
```

#### 7. `getByTestId()` - Test IDs (Last Resort)

Use when other locators aren't reliable. Configure the attribute name:

```typescript
// playwright.config.ts
use: {
  testIdAttribute: 'data-testid', // default
}

// In tests
await page.getByTestId('submit-button').click();
```

### Filtering Locators

```typescript
// Filter by text
const product = page.getByRole('listitem').filter({ hasText: 'iPhone' });

// Filter by descendant element
const row = page.getByRole('row').filter({
  has: page.getByRole('cell', { name: 'Active' })
});

// Negative filter
const otherItems = page.getByRole('listitem').filter({
  hasNot: page.getByText('Sold out')
});

// Filter by visibility
const visibleButtons = page.getByRole('button').filter({ visible: true });
```

### Chaining Locators

```typescript
// Narrow scope step by step
await page
  .getByRole('article')
  .filter({ hasText: 'Breaking News' })
  .getByRole('link', { name: 'Read more' })
  .click();

// Within a specific region
const sidebar = page.getByRole('complementary');
await sidebar.getByRole('link', { name: 'Settings' }).click();
```

### Locator Operators

```typescript
// AND - must match all conditions
const saveButton = page.getByRole('button').and(page.getByText('Save'));

// OR - matches any condition (use .first() to avoid strict mode error)
const submitButton = page
  .getByRole('button', { name: 'Submit' })
  .or(page.getByRole('button', { name: 'Send' }))
  .first();
```

### Handling Multiple Elements

```typescript
// Get count
const count = await page.getByRole('listitem').count();

// Get all elements
const items = await page.getByRole('listitem').all();

// Get specific element (avoid if possible - fragile)
await page.getByRole('listitem').first().click();
await page.getByRole('listitem').last().click();
await page.getByRole('listitem').nth(2).click();
```

### CSS and XPath (Avoid When Possible)

```typescript
// CSS selector
page.locator('button.submit-btn');
page.locator('#login-form input[type="email"]');

// XPath
page.locator('xpath=//button[@type="submit"]');
```

**Warning**: CSS and XPath selectors break when DOM structure changes. Always prefer role-based locators.

---

## Assertions

Playwright's web-first assertions automatically retry until the condition is met or timeout occurs.

### Page Assertions

```typescript
// URL
await expect(page).toHaveURL('https://example.com/dashboard');
await expect(page).toHaveURL(/.*dashboard/);

// Title
await expect(page).toHaveTitle('Dashboard');
await expect(page).toHaveTitle(/Dashboard/);
```

### Element Assertions

```typescript
const button = page.getByRole('button', { name: 'Submit' });
const input = page.getByLabel('Email');

// Visibility
await expect(button).toBeVisible();
await expect(button).toBeHidden();

// Enabled/Disabled state
await expect(button).toBeEnabled();
await expect(button).toBeDisabled();

// Text content
await expect(button).toHaveText('Submit');
await expect(button).toContainText('Sub');
await expect(button).toHaveText(/submit/i);

// Input values
await expect(input).toHaveValue('test@example.com');
await expect(input).toBeEmpty();

// Checkbox/Radio state
await expect(page.getByRole('checkbox')).toBeChecked();
await expect(page.getByRole('checkbox')).not.toBeChecked();

// Focus
await expect(input).toBeFocused();

// Attributes
await expect(button).toHaveAttribute('type', 'submit');
await expect(button).toHaveClass('btn-primary');
await expect(button).toHaveId('submit-btn');

// CSS
await expect(button).toHaveCSS('background-color', 'rgb(0, 128, 0)');

// Count
await expect(page.getByRole('listitem')).toHaveCount(5);
```

### Negation

```typescript
await expect(button).not.toBeVisible();
await expect(input).not.toBeEmpty();
```

### Soft Assertions

Continue test execution after failed assertions to collect all failures:

```typescript
await expect.soft(page.getByTestId('status')).toHaveText('Success');
await expect.soft(page.getByTestId('name')).toHaveText('John');
// Test continues even if above fail
await page.getByRole('button', { name: 'Next' }).click();
```

### Custom Assertion Messages

```typescript
await expect(button, 'Submit button should be visible after form loads').toBeVisible();
```

### Polling Assertions

For non-locator assertions that need retrying:

```typescript
await expect.poll(async () => {
  const response = await page.evaluate(() => fetch('/api/status'));
  return response.status;
}).toBe(200);
```

### Retry Code Blocks

```typescript
await expect(async () => {
  const response = await page.request.get('/api/data');
  expect(response.status()).toBe(200);
}).toPass({
  timeout: 10000,
  intervals: [1000, 2000, 5000],
});
```

### Non-Retrying Assertions

Standard Jest-style assertions (don't auto-retry):

```typescript
const content = await page.textContent('.status');
expect(content).toBe('Active');
expect(content).toContain('Act');
expect(content).toMatch(/active/i);

const count = await page.getByRole('listitem').count();
expect(count).toBeGreaterThan(0);
expect(count).toBeLessThanOrEqual(10);
```

---

## Page Object Models

Page Object Models (POMs) encapsulate page interactions and locators for better maintainability.

### Creating a Page Object

```typescript
// pages/login.page.ts
import { type Locator, type Page, expect } from '@playwright/test';

export class LoginPage {
  readonly page: Page;
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;
  readonly errorMessage: Locator;

  constructor(page: Page) {
    this.page = page;
    this.emailInput = page.getByLabel('Email');
    this.passwordInput = page.getByLabel('Password');
    this.submitButton = page.getByRole('button', { name: 'Sign in' });
    this.errorMessage = page.getByRole('alert');
  }

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }

  async expectError(message: string) {
    await expect(this.errorMessage).toContainText(message);
  }

  async expectLoggedIn() {
    await expect(this.page).toHaveURL('/dashboard');
  }
}
```

### Using Page Objects in Tests

```typescript
// tests/login.spec.ts
import { test } from '@playwright/test';
import { LoginPage } from '../pages/login.page';

test.describe('Login', () => {
  let loginPage: LoginPage;

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page);
    await loginPage.goto();
  });

  test('successful login', async () => {
    await loginPage.login('user@example.com', 'password123');
    await loginPage.expectLoggedIn();
  });

  test('shows error for invalid credentials', async () => {
    await loginPage.login('wrong@example.com', 'wrongpassword');
    await loginPage.expectError('Invalid credentials');
  });
});
```

### Page Object with Components

```typescript
// pages/components/header.component.ts
import { type Locator, type Page } from '@playwright/test';

export class HeaderComponent {
  readonly container: Locator;
  readonly logo: Locator;
  readonly searchInput: Locator;
  readonly userMenu: Locator;

  constructor(page: Page) {
    this.container = page.getByRole('banner');
    this.logo = this.container.getByRole('link', { name: 'Home' });
    this.searchInput = this.container.getByRole('searchbox');
    this.userMenu = this.container.getByRole('button', { name: /user menu/i });
  }

  async search(query: string) {
    await this.searchInput.fill(query);
    await this.searchInput.press('Enter');
  }

  async openUserMenu() {
    await this.userMenu.click();
  }
}

// pages/dashboard.page.ts
import { type Page } from '@playwright/test';
import { HeaderComponent } from './components/header.component';

export class DashboardPage {
  readonly page: Page;
  readonly header: HeaderComponent;

  constructor(page: Page) {
    this.page = page;
    this.header = new HeaderComponent(page);
  }
}
```

---

## Fixtures

Fixtures provide test isolation and reusable setup/teardown logic.

### Built-in Fixtures

```typescript
test('example', async ({
  page,        // Isolated page for this test
  context,     // Isolated browser context
  browser,     // Shared browser instance
  browserName, // 'chromium', 'firefox', or 'webkit'
  request,     // Isolated API request context
}) => {
  // ...
});
```

### Custom Fixtures

```typescript
// fixtures.ts
import { test as base, expect } from '@playwright/test';
import { LoginPage } from './pages/login.page';
import { DashboardPage } from './pages/dashboard.page';

type MyFixtures = {
  loginPage: LoginPage;
  dashboardPage: DashboardPage;
  authenticatedPage: DashboardPage;
};

export const test = base.extend<MyFixtures>({
  loginPage: async ({ page }, use) => {
    const loginPage = new LoginPage(page);
    await use(loginPage);
  },

  dashboardPage: async ({ page }, use) => {
    const dashboardPage = new DashboardPage(page);
    await use(dashboardPage);
  },

  // Fixture with setup
  authenticatedPage: async ({ page }, use) => {
    // Setup: Login
    await page.goto('/login');
    await page.getByLabel('Email').fill('user@example.com');
    await page.getByLabel('Password').fill('password123');
    await page.getByRole('button', { name: 'Sign in' }).click();
    await expect(page).toHaveURL('/dashboard');

    const dashboardPage = new DashboardPage(page);
    await use(dashboardPage);

    // Teardown: Logout (optional)
    await page.getByRole('button', { name: 'Logout' }).click();
  },
});

export { expect } from '@playwright/test';
```

### Using Custom Fixtures

```typescript
// tests/dashboard.spec.ts
import { test, expect } from '../fixtures';

test('can view dashboard when authenticated', async ({ authenticatedPage }) => {
  await expect(authenticatedPage.page.getByRole('heading', { name: 'Dashboard' })).toBeVisible();
});
```

### Worker-Scoped Fixtures

Shared across all tests in a worker process:

```typescript
const test = base.extend<{}, { workerStorageState: string }>({
  workerStorageState: [async ({ browser }, use) => {
    // Expensive setup done once per worker
    const context = await browser.newContext();
    const page = await context.newPage();
    await page.goto('/login');
    await page.getByLabel('Email').fill('admin@example.com');
    await page.getByLabel('Password').fill('adminpass');
    await page.getByRole('button', { name: 'Sign in' }).click();

    const storageState = await context.storageState();
    await use(JSON.stringify(storageState));

    await context.close();
  }, { scope: 'worker' }],
});
```

### Automatic Fixtures

Run automatically for every test:

```typescript
const test = base.extend({
  // Auto-runs for every test
  autoFixture: [async ({ page }, use) => {
    // Setup
    await page.addInitScript(() => {
      window.localStorage.setItem('analytics', 'disabled');
    });
    await use();
    // Teardown
  }, { auto: true }],
});
```

### Fixture Options

Make fixtures configurable:

```typescript
type Options = {
  defaultUser: string;
};

const test = base.extend<Options>({
  defaultUser: ['guest', { option: true }],
});

// Override in config
projects: [
  {
    name: 'admin',
    use: { defaultUser: 'admin@example.com' },
  },
]
```

---

## Mocking & Network Interception

### Mock API Responses

```typescript
test('displays mocked data', async ({ page }) => {
  // Mock the API before navigation
  await page.route('**/api/users', async route => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify([
        { id: 1, name: 'John Doe' },
        { id: 2, name: 'Jane Smith' },
      ]),
    });
  });

  await page.goto('/users');
  await expect(page.getByText('John Doe')).toBeVisible();
  await expect(page.getByText('Jane Smith')).toBeVisible();
});
```

### Modify Responses

```typescript
test('modifies API response', async ({ page }) => {
  await page.route('**/api/users', async route => {
    // Fetch the actual response
    const response = await route.fetch();
    const json = await response.json();

    // Modify the data
    json.push({ id: 999, name: 'Injected User' });

    // Return modified response
    await route.fulfill({ response, json });
  });

  await page.goto('/users');
});
```

### Mock Error Responses

```typescript
test('handles API errors gracefully', async ({ page }) => {
  await page.route('**/api/data', async route => {
    await route.fulfill({
      status: 500,
      contentType: 'application/json',
      body: JSON.stringify({ error: 'Internal Server Error' }),
    });
  });

  await page.goto('/data');
  await expect(page.getByText('Failed to load data')).toBeVisible();
});
```

### Abort Requests

```typescript
test('blocks analytics', async ({ page }) => {
  await page.route('**/*analytics*', route => route.abort());
  await page.goto('/');
});
```

### HAR File Recording & Replay

```typescript
// Record HAR file
test('record network', async ({ page }) => {
  await page.routeFromHAR('tests/hars/api.har', {
    url: '**/api/**',
    update: true, // Record mode
  });
  await page.goto('/');
  // Interact with page...
});

// Replay from HAR file
test('replay network', async ({ page }) => {
  await page.routeFromHAR('tests/hars/api.har', {
    url: '**/api/**',
    update: false, // Replay mode
  });
  await page.goto('/');
});
```

### Wait for Network Requests

```typescript
test('waits for API call', async ({ page }) => {
  // Start waiting before triggering action
  const responsePromise = page.waitForResponse('**/api/submit');

  await page.getByRole('button', { name: 'Submit' }).click();

  const response = await responsePromise;
  expect(response.status()).toBe(200);
});
```

---

## API Testing

Test your API directly without browser overhead.

### Basic API Tests

```typescript
import { test, expect } from '@playwright/test';

test.describe('API Tests', () => {
  test('GET /api/users returns users', async ({ request }) => {
    const response = await request.get('/api/users');

    expect(response.ok()).toBeTruthy();
    expect(response.status()).toBe(200);

    const users = await response.json();
    expect(users).toHaveLength(3);
    expect(users[0]).toHaveProperty('name');
  });

  test('POST /api/users creates user', async ({ request }) => {
    const response = await request.post('/api/users', {
      data: {
        name: 'New User',
        email: 'new@example.com',
      },
    });

    expect(response.status()).toBe(201);

    const user = await response.json();
    expect(user.name).toBe('New User');
  });

  test('DELETE /api/users/:id removes user', async ({ request }) => {
    const response = await request.delete('/api/users/1');
    expect(response.status()).toBe(204);
  });
});
```

### API Configuration

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    baseURL: 'https://api.example.com',
    extraHTTPHeaders: {
      'Authorization': `Bearer ${process.env.API_TOKEN}`,
      'Accept': 'application/json',
    },
  },
});
```

### Combining API and UI Tests

```typescript
test('creates post via API, verifies in UI', async ({ page, request }) => {
  // Create data via API
  const response = await request.post('/api/posts', {
    data: { title: 'Test Post', content: 'Test content' },
  });
  const post = await response.json();

  // Verify in UI
  await page.goto(`/posts/${post.id}`);
  await expect(page.getByRole('heading', { name: 'Test Post' })).toBeVisible();
});
```

---

## Test Retries & Parallelization

### Configuring Retries

```typescript
// playwright.config.ts
export default defineConfig({
  retries: process.env.CI ? 2 : 0,
});

// Or per-group
test.describe('Flaky tests', () => {
  test.describe.configure({ retries: 3 });

  test('might be flaky', async ({ page }) => {
    // ...
  });
});
```

### Detecting Retries

```typescript
test('handles retry', async ({ page }, testInfo) => {
  if (testInfo.retry) {
    // Clear cache on retry
    await page.evaluate(() => localStorage.clear());
  }
  // ...
});
```

### Parallel Execution

```typescript
// Enable fully parallel mode
export default defineConfig({
  fullyParallel: true,
});

// Or per file
test.describe.configure({ mode: 'parallel' });

// Serial mode for dependent tests
test.describe.configure({ mode: 'serial' });

test.describe.serial('Ordered tests', () => {
  test('step 1', async ({ page }) => { /* ... */ });
  test('step 2', async ({ page }) => { /* ... */ }); // Runs after step 1
});
```

### Sharding for CI

```bash
# Split tests across machines
npx playwright test --shard=1/3
npx playwright test --shard=2/3
npx playwright test --shard=3/3
```

---

## Debugging

### UI Mode

```bash
npx playwright test --ui
```

Interactive mode with:
- Watch mode for file changes
- Step-through test execution
- Time-travel debugging with DOM snapshots

### Debug Mode

```bash
npx playwright test --debug
```

Opens browser with Playwright Inspector for stepping through tests.

### Trace Viewer

Configure trace recording:

```typescript
// playwright.config.ts
use: {
  trace: 'on-first-retry', // or 'on', 'retain-on-failure', 'off'
}
```

View traces:

```bash
npx playwright show-report
```

Or upload to [trace.playwright.dev](https://trace.playwright.dev).

### VS Code Extension

- Set breakpoints in test files
- Run/debug individual tests
- View test results inline

### Console Logging

```typescript
test('debug example', async ({ page }) => {
  page.on('console', msg => console.log('PAGE LOG:', msg.text()));

  await page.goto('/');
  console.log('Current URL:', page.url());
});
```

### Pause Execution

```typescript
test('debug with pause', async ({ page }) => {
  await page.goto('/');
  await page.pause(); // Opens inspector
  await page.getByRole('button').click();
});
```

---

## Best Practices

### 1. Test User-Visible Behavior

```typescript
// ✅ Good: Tests what users see
test('shows success message after form submission', async ({ page }) => {
  await page.getByLabel('Email').fill('test@example.com');
  await page.getByRole('button', { name: 'Subscribe' }).click();
  await expect(page.getByText('Thanks for subscribing!')).toBeVisible();
});

// ❌ Bad: Tests implementation details
test('sets state correctly', async ({ page }) => {
  await page.getByLabel('Email').fill('test@example.com');
  const state = await page.evaluate(() => window.__REACT_STATE__);
  expect(state.email).toBe('test@example.com');
});
```

### 2. Use Resilient Locators

```typescript
// ✅ Resilient to UI changes
page.getByRole('button', { name: 'Submit' });
page.getByLabel('Email address');
page.getByText('Welcome back');

// ❌ Fragile - breaks with CSS/structure changes
page.locator('button.btn.btn-primary.submit-btn');
page.locator('#form > div:nth-child(2) > input');
page.locator('xpath=//div[@class="header"]/button[1]');
```

### 3. Keep Tests Isolated

```typescript
// ✅ Each test is independent
test.beforeEach(async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill('user@example.com');
  await page.getByLabel('Password').fill('password');
  await page.getByRole('button', { name: 'Sign in' }).click();
});

test('can view profile', async ({ page }) => {
  await page.getByRole('link', { name: 'Profile' }).click();
  await expect(page.getByRole('heading', { name: 'Profile' })).toBeVisible();
});

test('can update settings', async ({ page }) => {
  await page.getByRole('link', { name: 'Settings' }).click();
  // ...
});
```

### 4. Use Web-First Assertions

```typescript
// ✅ Auto-waits and retries
await expect(page.getByText('Loading...')).toBeHidden();
await expect(page.getByRole('alert')).toBeVisible();

// ❌ No auto-waiting - can cause flaky tests
const isVisible = await page.getByRole('alert').isVisible();
expect(isVisible).toBe(true);
```

### 5. Avoid Testing Third-Party Services

```typescript
// ✅ Mock external services
await page.route('**/api.stripe.com/**', route =>
  route.fulfill({
    status: 200,
    body: JSON.stringify({ success: true }),
  })
);

// ❌ Testing against live external APIs
test('processes payment', async ({ page }) => {
  // This can fail due to network issues, rate limits, etc.
  await page.goto('https://checkout.stripe.com/...');
});
```

### 6. Generate Locators

Use codegen to find optimal locators:

```bash
npx playwright codegen https://example.com
```

### 7. Use TypeScript with Strict Linting

```json
// tsconfig.json
{
  "compilerOptions": {
    "strict": true
  }
}

// .eslintrc
{
  "rules": {
    "@typescript-eslint/no-floating-promises": "error"
  }
}
```

### 8. Run Tests in CI

```yaml
# .github/workflows/playwright.yml
name: Playwright Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npx playwright install --with-deps
      - run: npx playwright test
      - uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: playwright-report
          path: playwright-report/
```

### 9. Keep Playwright Updated

```bash
npm install -D @playwright/test@latest
npx playwright install --with-deps
```

### 10. Use Soft Assertions for Comprehensive Feedback

```typescript
test('validates entire form', async ({ page }) => {
  await page.getByRole('button', { name: 'Submit' }).click();

  // Collect all validation errors
  await expect.soft(page.getByText('Email is required')).toBeVisible();
  await expect.soft(page.getByText('Password is required')).toBeVisible();
  await expect.soft(page.getByText('Name is required')).toBeVisible();
});
```

---

## Quick Reference

### Common Commands

| Command | Description |
|---------|-------------|
| `npx playwright test` | Run all tests |
| `npx playwright test --ui` | Run in UI mode |
| `npx playwright test --debug` | Run in debug mode |
| `npx playwright test --headed` | Run with visible browser |
| `npx playwright test --project=chromium` | Run specific browser |
| `npx playwright test -g "login"` | Run tests matching pattern |
| `npx playwright codegen` | Generate test code |
| `npx playwright show-report` | View HTML report |
| `npx playwright install` | Install browsers |

### Assertion Cheat Sheet

| Assertion | Description |
|-----------|-------------|
| `toBeVisible()` | Element is visible |
| `toBeHidden()` | Element is hidden |
| `toBeEnabled()` | Element is enabled |
| `toBeDisabled()` | Element is disabled |
| `toBeChecked()` | Checkbox/radio is checked |
| `toBeFocused()` | Element has focus |
| `toHaveText(text)` | Element has exact text |
| `toContainText(text)` | Element contains text |
| `toHaveValue(value)` | Input has value |
| `toHaveAttribute(name, value)` | Element has attribute |
| `toHaveCount(n)` | Locator matches n elements |
| `toHaveURL(url)` | Page has URL |
| `toHaveTitle(title)` | Page has title |

---

## Idempotent Tests (Round-Trip Cleanup)

Tests should clean up the resources they create to ensure isolation and repeatability. This section covers patterns for writing idempotent end-to-end tests.

### Why Idempotent Tests Matter

- **Isolation**: Tests don't affect each other
- **Repeatability**: Tests can run multiple times without manual cleanup
- **CI/CD Friendly**: No accumulated test data in environments
- **Debugging**: Failures are easier to reproduce

### Pattern 1: Single Test Create-Verify-Delete

The simplest pattern—create, verify, and delete within a single test.

```typescript
import { test, expect } from '@playwright/test';

/**
 * Helper to generate unique titles to avoid conflicts
 */
function uniqueTodoTitle(prefix: string): string {
  return `${prefix}-${Date.now()}-${Math.random().toString(36).slice(2, 7)}`;
}

test.describe('Todo CRUD - Single Test Cleanup', () => {
  test('creates, verifies, and deletes a todo', async ({ page }) => {
    const todoTitle = uniqueTodoTitle('test-todo');

    await page.goto('/todos');

    // CREATE
    await page.getByPlaceholder('What needs to be done?').fill(todoTitle);
    await page.getByPlaceholder('What needs to be done?').press('Enter');

    // VERIFY creation
    const todoItem = page.getByRole('listitem').filter({ hasText: todoTitle });
    await expect(todoItem).toBeVisible();

    // CLEANUP - Delete the todo we created
    await todoItem.hover();
    await todoItem.getByRole('button', { name: 'Delete' }).click();

    // VERIFY cleanup
    await expect(todoItem).toBeHidden();
  });
});
```

### Pattern 2: afterEach Hook Cleanup

Track created resources and clean them up in `afterEach`.

```typescript
test.describe('Todo Operations - Hook Cleanup', () => {
  let createdTodoTitles: string[] = [];

  test.afterEach(async ({ page }) => {
    // Clean up all todos created during the test
    for (const title of createdTodoTitles) {
      const todoItem = page.getByRole('listitem').filter({ hasText: title });
      if (await todoItem.isVisible()) {
        await todoItem.hover();
        await todoItem.getByRole('button', { name: 'Delete' }).click();
        await expect(todoItem).toBeHidden();
      }
    }
    createdTodoTitles = [];
  });

  test('can mark todo as complete', async ({ page }) => {
    const todoTitle = uniqueTodoTitle('complete-test');
    createdTodoTitles.push(todoTitle);

    await page.goto('/todos');

    // Create todo
    await page.getByPlaceholder('What needs to be done?').fill(todoTitle);
    await page.getByPlaceholder('What needs to be done?').press('Enter');

    // Mark as complete
    const todoItem = page.getByRole('listitem').filter({ hasText: todoTitle });
    await todoItem.getByRole('checkbox').check();

    // Verify completed state
    await expect(todoItem).toHaveClass(/completed/);
    await expect(todoItem.getByRole('checkbox')).toBeChecked();

    // afterEach will clean up
  });

  test('can edit todo title', async ({ page }) => {
    const originalTitle = uniqueTodoTitle('edit-original');
    const newTitle = uniqueTodoTitle('edit-updated');
    createdTodoTitles.push(newTitle); // Track the final title for cleanup

    await page.goto('/todos');

    // Create todo
    await page.getByPlaceholder('What needs to be done?').fill(originalTitle);
    await page.getByPlaceholder('What needs to be done?').press('Enter');

    // Edit todo (double-click to edit)
    const todoItem = page.getByRole('listitem').filter({ hasText: originalTitle });
    await todoItem.dblclick();

    const editInput = todoItem.getByRole('textbox');
    await editInput.clear();
    await editInput.fill(newTitle);
    await editInput.press('Enter');

    // Verify edit
    await expect(page.getByRole('listitem').filter({ hasText: newTitle })).toBeVisible();
    await expect(page.getByRole('listitem').filter({ hasText: originalTitle })).toBeHidden();

    // afterEach will clean up using newTitle
  });
});
```

### Pattern 3: API-Based Cleanup (Recommended)

Clean up via API calls—faster and more reliable than UI cleanup.

```typescript
test.describe('Todo Operations - API Cleanup', () => {
  let createdTodoIds: string[] = [];

  test.afterEach(async ({ request }) => {
    // Clean up via API - much faster than UI cleanup
    for (const id of createdTodoIds) {
      await request.delete(`/api/todos/${id}`);
    }
    createdTodoIds = [];
  });

  test('creates todo and verifies in list', async ({ page, request }) => {
    const todoTitle = uniqueTodoTitle('api-cleanup-test');

    // Create via API to get ID for cleanup
    const createResponse = await request.post('/api/todos', {
      data: { title: todoTitle, completed: false }
    });
    const todo = await createResponse.json();
    createdTodoIds.push(todo.id);

    // Verify in UI
    await page.goto('/todos');
    await expect(page.getByRole('listitem').filter({ hasText: todoTitle })).toBeVisible();

    // API cleanup happens in afterEach
  });

  test('bulk creates todos and filters by status', async ({ page, request }) => {
    const activeTodo = uniqueTodoTitle('active');
    const completedTodo = uniqueTodoTitle('completed');

    // Create todos via API
    const [activeRes, completedRes] = await Promise.all([
      request.post('/api/todos', { data: { title: activeTodo, completed: false } }),
      request.post('/api/todos', { data: { title: completedTodo, completed: true } }),
    ]);

    createdTodoIds.push((await activeRes.json()).id);
    createdTodoIds.push((await completedRes.json()).id);

    await page.goto('/todos');

    // Verify both visible initially
    await expect(page.getByRole('listitem').filter({ hasText: activeTodo })).toBeVisible();
    await expect(page.getByRole('listitem').filter({ hasText: completedTodo })).toBeVisible();

    // Filter to active only
    await page.getByRole('link', { name: 'Active' }).click();
    await expect(page.getByRole('listitem').filter({ hasText: activeTodo })).toBeVisible();
    await expect(page.getByRole('listitem').filter({ hasText: completedTodo })).toBeHidden();

    // Filter to completed only
    await page.getByRole('link', { name: 'Completed' }).click();
    await expect(page.getByRole('listitem').filter({ hasText: activeTodo })).toBeHidden();
    await expect(page.getByRole('listitem').filter({ hasText: completedTodo })).toBeVisible();
  });
});
```

### Pattern 4: Fixture-Based Setup & Cleanup

Encapsulate resource management in a custom fixture.

```typescript
import { test as base } from '@playwright/test';

type TodoFixtures = {
  todoManager: {
    create: (title: string, completed?: boolean) => Promise<{ id: string; title: string }>;
    getAll: () => { id: string; title: string }[];
  };
};

const test = base.extend<TodoFixtures>({
  todoManager: async ({ request }, use) => {
    const createdTodos: { id: string; title: string }[] = [];

    const manager = {
      create: async (title: string, completed = false) => {
        const response = await request.post('/api/todos', {
          data: { title, completed }
        });
        const todo = await response.json();
        createdTodos.push({ id: todo.id, title: todo.title });
        return todo;
      },
      getAll: () => [...createdTodos],
    };

    // Provide the fixture to the test
    await use(manager);

    // Cleanup after test completes
    for (const todo of createdTodos) {
      await request.delete(`/api/todos/${todo.id}`);
    }
  },
});

export { test };

// Usage in tests
test('can reorder todos via drag and drop', async ({ page, todoManager }) => {
  // Create test data using fixture
  const todo1 = await todoManager.create(uniqueTodoTitle('first'));
  const todo2 = await todoManager.create(uniqueTodoTitle('second'));
  const todo3 = await todoManager.create(uniqueTodoTitle('third'));

  await page.goto('/todos');

  // Verify initial order
  const items = page.getByRole('listitem');
  await expect(items.nth(0)).toContainText(todo1.title);
  await expect(items.nth(1)).toContainText(todo2.title);
  await expect(items.nth(2)).toContainText(todo3.title);

  // Drag todo3 to first position
  const source = items.filter({ hasText: todo3.title });
  const target = items.filter({ hasText: todo1.title });
  await source.dragTo(target);

  // Verify new order
  await expect(items.nth(0)).toContainText(todo3.title);
  await expect(items.nth(1)).toContainText(todo1.title);
  await expect(items.nth(2)).toContainText(todo2.title);

  // Fixture cleanup happens automatically
});

test('displays correct counts in footer', async ({ page, todoManager }) => {
  // Create mixed todos
  await todoManager.create(uniqueTodoTitle('active-1'), false);
  await todoManager.create(uniqueTodoTitle('active-2'), false);
  await todoManager.create(uniqueTodoTitle('completed-1'), true);

  await page.goto('/todos');

  // Verify counts
  await expect(page.getByTestId('todo-count')).toHaveText('2 items left');

  // Complete one more
  const activeItem = page.getByRole('listitem').filter({ hasText: 'active-1' });
  await activeItem.getByRole('checkbox').check();

  await expect(page.getByTestId('todo-count')).toHaveText('1 item left');
});
```

### Pattern 5: Database Transaction Rollback

For backends that support it, wrap tests in transactions that rollback.

```typescript
test.describe('Todo Operations - Transaction Rollback', () => {
  test.beforeEach(async ({ request }) => {
    // Start a database transaction (requires backend support)
    await request.post('/api/test/begin-transaction');
  });

  test.afterEach(async ({ request }) => {
    // Rollback all changes made during the test
    await request.post('/api/test/rollback-transaction');
  });

  test('can use "clear completed" feature', async ({ page, request }) => {
    // Seed test data
    await request.post('/api/todos', { data: { title: 'Keep this', completed: false } });
    await request.post('/api/todos', { data: { title: 'Delete this 1', completed: true } });
    await request.post('/api/todos', { data: { title: 'Delete this 2', completed: true } });

    await page.goto('/todos');

    // Verify initial state
    await expect(page.getByRole('listitem')).toHaveCount(3);

    // Clear completed
    await page.getByRole('button', { name: 'Clear completed' }).click();

    // Verify only active todo remains
    await expect(page.getByRole('listitem')).toHaveCount(1);
    await expect(page.getByText('Keep this')).toBeVisible();

    // Transaction rollback in afterEach restores DB state
  });
});
```

### Pattern 6: Isolated Test User Accounts

Create a unique user per test file for complete isolation.

```typescript
test.describe('Todo Operations - Isolated User', () => {
  let testUserId: string;
  let authToken: string;

  test.beforeAll(async ({ request }) => {
    // Create a unique test user for this test file
    const response = await request.post('/api/test/create-user', {
      data: {
        email: `test-${Date.now()}@example.com`,
        password: 'testpassword123'
      }
    });
    const user = await response.json();
    testUserId = user.id;
    authToken = user.token;
  });

  test.afterAll(async ({ request }) => {
    // Delete the test user and all their data
    await request.delete(`/api/test/users/${testUserId}`, {
      headers: { Authorization: `Bearer ${authToken}` }
    });
  });

  test.beforeEach(async ({ page }) => {
    // Set auth cookie/token before each test
    await page.goto('/');
    await page.evaluate((token) => {
      localStorage.setItem('authToken', token);
    }, authToken);
  });

  test('new user sees empty todo list', async ({ page }) => {
    await page.goto('/todos');
    await expect(page.getByText('No todos yet')).toBeVisible();
  });

  test('user can create their first todo', async ({ page }) => {
    const todoTitle = uniqueTodoTitle('first-todo');

    await page.goto('/todos');
    await page.getByPlaceholder('What needs to be done?').fill(todoTitle);
    await page.getByPlaceholder('What needs to be done?').press('Enter');

    await expect(page.getByRole('listitem').filter({ hasText: todoTitle })).toBeVisible();
    // User deletion in afterAll cleans up all todos
  });
});
```

### Pattern 7: Page Object with Built-in Cleanup

Encapsulate cleanup logic within your page objects.

```typescript
import { type Page, expect } from '@playwright/test';

class TodoPage {
  private createdTodoIds: string[] = [];

  constructor(
    private page: Page,
    private request: any
  ) {}

  async goto() {
    await this.page.goto('/todos');
  }

  async createTodo(title: string): Promise<string> {
    await this.page.getByPlaceholder('What needs to be done?').fill(title);
    await this.page.getByPlaceholder('What needs to be done?').press('Enter');

    // Get the ID from the DOM for cleanup tracking
    const todoItem = this.page.getByRole('listitem').filter({ hasText: title });
    await expect(todoItem).toBeVisible();
    const id = await todoItem.getAttribute('data-todo-id') ?? '';
    this.createdTodoIds.push(id);

    return id;
  }

  async createTodoViaApi(title: string, completed = false): Promise<string> {
    const response = await this.request.post('/api/todos', {
      data: { title, completed }
    });
    const todo = await response.json();
    this.createdTodoIds.push(todo.id);
    return todo.id;
  }

  async completeTodo(title: string) {
    const todoItem = this.page.getByRole('listitem').filter({ hasText: title });
    await todoItem.getByRole('checkbox').check();
  }

  async deleteTodo(title: string) {
    const todoItem = this.page.getByRole('listitem').filter({ hasText: title });
    await todoItem.hover();
    await todoItem.getByRole('button', { name: 'Delete' }).click();
    await expect(todoItem).toBeHidden();
  }

  getTodoItem(title: string) {
    return this.page.getByRole('listitem').filter({ hasText: title });
  }

  async cleanup() {
    // Clean up all tracked todos via API
    for (const id of this.createdTodoIds) {
      try {
        await this.request.delete(`/api/todos/${id}`);
      } catch {
        // Ignore errors (todo may already be deleted)
      }
    }
    this.createdTodoIds = [];
  }
}

// Usage
test.describe('Todo Operations - Page Object Cleanup', () => {
  let todoPage: TodoPage;

  test.beforeEach(async ({ page, request }) => {
    todoPage = new TodoPage(page, request);
    await todoPage.goto();
  });

  test.afterEach(async () => {
    await todoPage.cleanup();
  });

  test('can create multiple todos and complete them', async () => {
    const todo1 = uniqueTodoTitle('task-1');
    const todo2 = uniqueTodoTitle('task-2');
    const todo3 = uniqueTodoTitle('task-3');

    await todoPage.createTodo(todo1);
    await todoPage.createTodo(todo2);
    await todoPage.createTodo(todo3);

    await todoPage.completeTodo(todo1);
    await todoPage.completeTodo(todo3);

    await expect(todoPage.getTodoItem(todo1).getByRole('checkbox')).toBeChecked();
    await expect(todoPage.getTodoItem(todo2).getByRole('checkbox')).not.toBeChecked();
    await expect(todoPage.getTodoItem(todo3).getByRole('checkbox')).toBeChecked();
  });
});
```

### Pattern 8: Cleanup with Retry Logic

Handle flaky cleanup operations with retries and backoff.

```typescript
test.describe('Todo Operations - Resilient Cleanup', () => {
  const createdResources: Array<{ type: 'todo' | 'list'; id: string }> = [];

  async function cleanupWithRetry(
    request: any,
    resource: { type: string; id: string },
    maxRetries = 3
  ) {
    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        const endpoint = resource.type === 'todo'
          ? `/api/todos/${resource.id}`
          : `/api/lists/${resource.id}`;

        const response = await request.delete(endpoint);
        if (response.ok() || response.status() === 404) {
          return; // Success or already deleted
        }

        if (attempt < maxRetries) {
          await new Promise(r => setTimeout(r, 1000 * attempt)); // Backoff
        }
      } catch (error) {
        if (attempt === maxRetries) {
          console.error(`Failed to cleanup ${resource.type} ${resource.id}:`, error);
        }
      }
    }
  }

  test.afterEach(async ({ request }) => {
    // Clean up in reverse order (todos before lists)
    const sortedResources = [...createdResources].reverse();

    await Promise.all(
      sortedResources.map(resource => cleanupWithRetry(request, resource))
    );

    createdResources.length = 0;
  });

  test('can create todo in a new list', async ({ page, request }) => {
    // Create a list first
    const listResponse = await request.post('/api/lists', {
      data: { name: uniqueTodoTitle('test-list') }
    });
    const list = await listResponse.json();
    createdResources.push({ type: 'list', id: list.id });

    // Create a todo in that list
    const todoResponse = await request.post('/api/todos', {
      data: {
        title: uniqueTodoTitle('list-todo'),
        listId: list.id
      }
    });
    const todo = await todoResponse.json();
    createdResources.push({ type: 'todo', id: todo.id });

    // Verify in UI
    await page.goto(`/lists/${list.id}`);
    await expect(page.getByRole('heading', { name: list.name })).toBeVisible();
    await expect(page.getByRole('listitem').filter({ hasText: todo.title })).toBeVisible();
  });
});
```

### Cleanup Pattern Comparison

| Pattern | Use When | Pros | Cons |
|---------|----------|------|------|
| **Single Test** | Simple CRUD operations | Self-contained, easy to understand | Verbose, slow if many operations |
| **afterEach Hook** | Multiple tests share cleanup logic | DRY, automatic | Cleanup can fail, leaving debris |
| **API Cleanup** | Backend supports REST API | Fast, reliable | Requires API access |
| **Fixtures** | Reusable setup across test files | Type-safe, composable | More boilerplate |
| **Transaction Rollback** | Database supports transactions | Perfect isolation | Requires backend support |
| **Isolated User** | Multi-tenant apps | Complete isolation | Slower setup |
| **Page Object** | Large test suites | Encapsulated, maintainable | More abstraction |
| **Retry Logic** | Flaky cleanup operations | Resilient | More complex |

### Best Practice: Combining Patterns

For production test suites, combine multiple patterns:

```typescript
import { test as base, expect } from '@playwright/test';

// 1. Unique identifiers prevent conflicts
function uniqueId(prefix: string): string {
  return `${prefix}-${Date.now()}-${Math.random().toString(36).slice(2, 7)}`;
}

// 2. Fixture handles resource tracking and cleanup
const test = base.extend<{ testData: TestDataManager }>({
  testData: async ({ request }, use) => {
    const manager = new TestDataManager(request);
    await use(manager);
    await manager.cleanup(); // 3. API cleanup is fast and reliable
  },
});

class TestDataManager {
  private resources: Array<{ endpoint: string; id: string }> = [];

  constructor(private request: any) {}

  async createTodo(title: string) {
    const response = await this.request.post('/api/todos', {
      data: { title, completed: false }
    });
    const todo = await response.json();
    this.resources.push({ endpoint: '/api/todos', id: todo.id });
    return todo;
  }

  // 4. Retry logic for resilience
  async cleanup() {
    for (const resource of this.resources.reverse()) {
      for (let i = 0; i < 3; i++) {
        try {
          const res = await this.request.delete(`${resource.endpoint}/${resource.id}`);
          if (res.ok() || res.status() === 404) break;
        } catch {
          if (i === 2) console.error(`Failed to cleanup: ${resource.id}`);
        }
      }
    }
  }
}

export { test, expect, uniqueId };
```
