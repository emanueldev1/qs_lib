import { createContext, useContext, useState } from "react"
import { useNuiEvent } from "../hooks/useNuiEvent"
import { debugData } from "../utils/debugData"

debugData([
  {
    action: "loadLocales",
    data: [
      "en",
      "fr",
      "de",
      "it",
      "es",
      "pt-BR",
      "pl",
      "ru",
      "ko",
      "zh-TW",
      "ja",
      "es-MX",
      "zh-CN"
    ]
  }
])

debugData([
  {
    action: "setLocale",
    data: {
      language: "English",
      ui: {
        cancel: "Cancel",
        close: "Close",
        confirm: "Confirm",
        more: "More..."
      }
    }
  }
])

const LocaleCtx = createContext(null)

const LocaleProvider = ({ children }) => {
  const [locale, setLocale] = useState({
    language: "",
    ui: {
      cancel: "",
      close: "",
      confirm: "",
      more: ""
    }
  })

  useNuiEvent("setLocale", async data => setLocale(data))

  return (
    <LocaleCtx.Provider value={{ locale, setLocale }}>
      {children}
    </LocaleCtx.Provider>
  )
}

export default LocaleProvider

export const useLocales = () => useContext(LocaleCtx)
