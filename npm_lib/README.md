# qs_lib JS wrapper

Not all qs_lib functions found in Lua are supported, the ones that are will have a JS example
on the documentation.

You still need to use and have the qs_lib resource included into the resource you are using the npm package in.

## Installation

```yaml
# With pnpm
pnpm add @emanueldevv/qs_lib

# With Yarn
yarn add @emanueldevv/qs_lib

# With npm
npm install @emanueldevv/qs_lib
```

## Usage
You can either import the lib from client or server files or deconstruct the object and import only certain functions
you may require.

```js
import lib from '@emanueldevv/qs_lib/client'
```

```js
import lib from '@emanueldevv/qs_lib/server'
```

```js
import { checkDependency } from '@emanueldevv/qs_lib/shared';
```

## Documentation
[View documentation](https://quasar_store.github.io/docs/qs_lib)
