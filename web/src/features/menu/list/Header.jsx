// -- This file contains code adapted from ox_lib, developed by the Overextended team.
// -- Original repository: https://github.com/overextended/ox_lib
// -- License: GNU Lesser General Public License v3.0 (LGPL-3.0), available at https://www.gnu.org/licenses/lgpl-3.0.html
// -- Modifications by emanueldev1 for the qs_lib project, licensed under LGPL-3.0.

import { Box, createStyles, Text } from "@mantine/core"
import React from "react"

const useStyles = createStyles(theme => ({
  container: {
    textAlign: "center",
    borderTopLeftRadius: theme.radius.md,
    borderTopRightRadius: theme.radius.md,
    backgroundColor: theme.colors.dark[6],
    height: 60,
    width: 384,
    display: "flex",
    justifyContent: "center",
    alignItems: "center"
  },
  heading: {
    fontSize: 24,
    textTransform: "uppercase",
    fontWeight: 500
  }
}))

const Header = ({ title }) => {
  const { classes } = useStyles()

  return (
    <Box className={classes.container}>
      <Text className={classes.heading}>{title}</Text>
    </Box>
  )
}

export default React.memo(Header)
