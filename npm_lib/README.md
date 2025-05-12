# qs_lib JS/TS wrapper

Not all qs_lib functions found in Lua are supported, the ones that are will have a JS/TS example
on the documentation.

You still need to use and have the qs_lib resource included into the resource you are using the npm package in.

## Installation

```yaml
# With pnpm
pnpm add @quasar_store/qs_lib

# With Yarn
yarn add @quasar_store/qs_lib

# With npm
npm install @quasar_store/qs_lib
```

## Usage
You can either import the lib from client or server files or deconstruct the object and import only certain functions
you may require.

```ts
import lib from '@quasar_store/qs_lib/client'
```

```ts
import lib from '@quasar_store/qs_lib/server'
```

```ts
import { checkDependency } from '@quasar_store/qs_lib/shared';
```

## Documentation
[View documentation](https://quasar_store.github.io/docs/qs_lib)