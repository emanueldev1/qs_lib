// -- This file contains code adapted from ox_lib, developed by the Overextended team.
// -- Original repository: https://github.com/overextended/ox_lib
// -- License: GNU Lesser General Public License v3.0 (LGPL-3.0), available at https://www.gnu.org/licenses/lgpl-3.0.html
// -- Modifications by emanueldev1 for the qs_lib project, licensed under LGPL-3.0.

import { Box, createStyles, Group, Progress, Stack, Text } from "@mantine/core"
import React, { forwardRef } from "react"
import CustomCheckbox from "./CustomCheckbox"
import { isIconUrl } from "../../../utils/isIconUrl"
import LibIcon from "../../../components/LibIcon"

const useStyles = createStyles((theme, params) => ({
  buttonContainer: {
    backgroundColor: theme.colors.dark[6],
    borderRadius: theme.radius.md,
    padding: 2,
    height: 60,
    scrollMargin: 8,
    "&:focus": {
      backgroundColor: theme.colors.dark[4],
      outline: "none"
    }
  },
  iconImage: {
    maxWidth: 32
  },
  buttonWrapper: {
    paddingLeft: 5,
    paddingRight: 12,
    height: "100%"
  },
  iconContainer: {
    display: "flex",
    alignItems: "center",
    width: 32,
    height: 32
  },
  icon: {
    fontSize: 24,
    color: params.iconColor || theme.colors.dark[2]
  },
  label: {
    color: theme.colors.dark[2],
    textTransform: "uppercase",
    fontSize: 12,
    verticalAlign: "middle"
  },
  chevronIcon: {
    fontSize: 14,
    color: theme.colors.dark[2]
  },
  scrollIndexValue: {
    color: theme.colors.dark[2],
    textTransform: "uppercase",
    fontSize: 14
  },
  progressStack: {
    width: "100%",
    marginRight: 5
  },
  progressLabel: {
    verticalAlign: "middle",
    marginBottom: 3
  }
}))

const ListItem = forwardRef(({ item, index, scrollIndex, checked }, ref) => {
  const { classes } = useStyles({ iconColor: item.iconColor })

  return (
    <Box
      tabIndex={index}
      className={classes.buttonContainer}
      key={`item-${index}`}
      ref={element => {
        if (ref)
          // @ts-ignore i cba
          return (ref.current = [...ref.current, element])
      }}
    >
      <Group spacing={15} noWrap className={classes.buttonWrapper}>
        {item.icon && (
          <Box className={classes.iconContainer}>
            {typeof item.icon === "string" && isIconUrl(item.icon) ? (
              <img
                src={item.icon}
                alt="Missing image"
                className={classes.iconImage}
              />
            ) : (
              <LibIcon
                icon={item.icon}
                className={classes.icon}
                fixedWidth
                animation={item.iconAnimation}
              />
            )}
          </Box>
        )}
        {Array.isArray(item.values) ? (
          <Group position="apart" w="100%">
            <Stack spacing={0} justify="space-between">
              <Text className={classes.label}>{item.label}</Text>
              <Text>
                {typeof item.values[scrollIndex] === "object"
                  ? // @ts-ignore for some reason even checking the type TS still thinks it's a string
                    item.values[scrollIndex].label
                  : item.values[scrollIndex]}
              </Text>
            </Stack>
            <Group spacing={1} position="center">
              <LibIcon icon="chevron-left" className={classes.chevronIcon} />
              <Text className={classes.scrollIndexValue}>
                {scrollIndex + 1}/{item.values.length}
              </Text>
              <LibIcon icon="chevron-right" className={classes.chevronIcon} />
            </Group>
          </Group>
        ) : item.checked !== undefined ? (
          <Group position="apart" w="100%">
            <Text>{item.label}</Text>
            <CustomCheckbox checked={checked}></CustomCheckbox>
          </Group>
        ) : item.progress !== undefined ? (
          <Stack className={classes.progressStack} spacing={0}>
            <Text className={classes.progressLabel}>{item.label}</Text>
            <Progress
              value={item.progress}
              color={item.colorScheme || "dark.0"}
              styles={theme => ({
                root: { backgroundColor: theme.colors.dark[3] }
              })}
            />
          </Stack>
        ) : (
          <Text>{item.label}</Text>
        )}
      </Group>
    </Box>
  )
})

export default React.memo(ListItem)
