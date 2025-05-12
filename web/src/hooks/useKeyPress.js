import React from "react"

export const useKeyPress = targetKey => {
  const [keyPressed, setKeyPressed] = React.useState(false)

  const downHandler = React.useCallback(
    ({ key }) => {
      if (key.toLowerCase() === targetKey) {
        setKeyPressed(true)
      }
    },
    [targetKey]
  )

  const upHandler = React.useCallback(
    ({ key }) => {
      if (key.toLowerCase() === targetKey) {
        setKeyPressed(false)
      }
    },
    [targetKey]
  )

  React.useEffect(() => {
    window.addEventListener("keydown", downHandler)
    window.addEventListener("keyup", upHandler)

    return () => {
      window.removeEventListener("keydown", downHandler)
      window.removeEventListener("keyup", upHandler)
    }
  }, [downHandler, upHandler])

  return keyPressed
}
