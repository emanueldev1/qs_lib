// -- This file contains code adapted from ox_lib, developed by the Overextended team.
// -- Original repository: https://github.com/overextended/ox_lib
// -- License: GNU Lesser General Public License v3.0 (LGPL-3.0), available at https://www.gnu.org/licenses/lgpl-3.0.html
// -- Modifications by emanueldev1 for the qs_lib project, licensed under LGPL-3.0.

import { Title } from "@mantine/core"

const MarkdownComponents = {
  h1: ({ node, ...props }) => <Title {...props} />,
  h2: ({ node, ...props }) => <Title order={2} {...props} />,
  h3: ({ node, ...props }) => <Title order={3} {...props} />
}

export default MarkdownComponents
