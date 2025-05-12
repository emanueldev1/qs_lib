import { Title } from "@mantine/core"

const MarkdownComponents = {
  h1: ({ node, ...props }) => <Title {...props} />,
  h2: ({ node, ...props }) => <Title order={2} {...props} />,
  h3: ({ node, ...props }) => <Title order={3} {...props} />
}

export default MarkdownComponents
