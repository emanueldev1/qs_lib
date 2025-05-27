// -- This file contains code adapted from ox_lib, developed by the Overextended team.
// -- Original repository: https://github.com/overextended/ox_lib
// -- License: GNU Lesser General Public License v3.0 (LGPL-3.0), available at https://www.gnu.org/licenses/lgpl-3.0.html
// -- Modifications by emanueldev1 for the qs_lib project, licensed under LGPL-3.0.

import { Checkbox, createStyles } from "@mantine/core"

const useStyles = createStyles(theme => ({
  root: {
    display: "flex",
    alignItems: "center"
  },
  input: {
    backgroundColor: theme.colors.dark[7],
    "&:checked": {
      backgroundColor: theme.colors.dark[2],
      borderColor: theme.colors.dark[2]
    }
  },
  inner: {
    "> svg > path": {
      fill: theme.colors.dark[6]
    }
  }
}))

const CustomCheckbox = ({ checked }) => {
  const { classes } = useStyles()
  return (
    <Checkbox
      checked={checked}
      size="md"
      classNames={{
        root: classes.root,
        input: classes.input,
        inner: classes.inner
      }}
    />
  )
}

export default CustomCheckbox
