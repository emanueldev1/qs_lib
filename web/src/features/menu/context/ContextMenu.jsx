import { useNuiEvent } from "../../../hooks/useNuiEvent"
import { useEffect, useState } from "react"
import ContextButton from "./components/ContextButton"
import { fetchNui } from "../../../utils/fetchNui"
import ReactMarkdown from "react-markdown"
import HeaderButton from "./components/HeaderButton"
import MarkdownComponents from "../../../config/MarkdownComponents"

const openMenu = id => {
  fetchNui("handleOpenContext", { id: id, back: true })
}

const ContextMenu = () => {
  const [visible, setVisible] = useState(false)
  const [contextMenu, setContextMenu] = useState({
    title: "",
    options: { "": { description: "", metadata: [] } }
  })

  const closeCurrentMenu = () => {
    if (contextMenu.canClose === false) return
    setVisible(false)
    fetchNui("closeCurrentMenu")
  }

  // Hides the context menu on ESC
  useEffect(() => {
    if (!visible) return

    const keyHandler = e => {
      if (["Escape"].includes(e.code)) closeCurrentMenu()
    }

    window.addEventListener("keydown", keyHandler)

    return () => window.removeEventListener("keydown", keyHandler)
  }, [visible])

  useNuiEvent("hideContext", () => setVisible(false))

  useNuiEvent("showContext", async data => {
    if (visible) {
      setVisible(false)
      await new Promise(resolve => setTimeout(resolve, 100))
    }
    setContextMenu(data)
    setVisible(true)
  })

  return (
    <div
      className={` absolute top-[16%] right-[26%] w-[430px] h-[590px] ${
        visible ? " animate-fade-in " : " animate-fade-out"
      }`}
    >
      <div className="flex flex-row gap-2 mb-[10px] px-8">
        {contextMenu.menu && (
          <HeaderButton
            icon="chevron-left"
            iconSize={16}
            handleClick={() => openMenu(contextMenu.menu)}
          />
        )}
        <div className="rounded-md bg-background flex-[1_85%]">
          <p className="text-foreground text-[12px] font-[400] p-[12px] text-center">
            <ReactMarkdown components={MarkdownComponents}>
              {contextMenu.title}
            </ReactMarkdown>
          </p>
        </div>
        <HeaderButton
          icon="xmark"
          canClose={contextMenu.canClose}
          iconSize={18}
          handleClick={closeCurrentMenu}
        />
      </div>
      <div className="h-[560px] overflow-y-scroll px-8">
        <div className="flex flex-col gap-1">
          {Object.entries(contextMenu.options).map((option, index) => (
            <ContextButton option={option} key={`context-item-${index}`} />
          ))}
        </div>
      </div>
    </div>
  )
}

export default ContextMenu
