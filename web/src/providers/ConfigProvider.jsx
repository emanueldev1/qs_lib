import { createContext, useContext, useEffect, useState } from "react"
import { fetchNui } from "../utils/fetchNui"

const ConfigCtx = createContext(null)

const ConfigProvider = ({ children }) => {
  const [config, setConfig] = useState({
    primaryColor: "blue",
    primaryShade: 6
  })

  useEffect(() => {
    fetchNui("getSettings").then(data => setConfig(data))
  }, [])

  return (
    <ConfigCtx.Provider value={{ config, setConfig }}>
      {children}
    </ConfigCtx.Provider>
  )
}

export default ConfigProvider

export const useConfig = () => useContext(ConfigCtx)
