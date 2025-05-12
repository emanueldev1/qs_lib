import React from "react"
import { useNuiEvent } from "../../hooks/useNuiEvent"
import ReactMarkdown from "react-markdown"
import ScaleFade from "../../transitions/ScaleFade"
import remarkGfm from "remark-gfm"
import MarkdownComponents from "../../config/MarkdownComponents"
import LibIcon from "../../components/LibIcon"

const TextUI = () => {
  const [data, setData] = React.useState({
    text: "",
    position: "right-center"
  })
  const [visible, setVisible] = React.useState(false)

  useNuiEvent("textUi", data => {
    if (!data.position) data.position = "right-center" // Default right position
    setData(data)
    setVisible(true)
  })

  useNuiEvent("textUiHide", () => setVisible(false))

  // Dynamic positioning classes based on data.position
  const getPositionClasses = () => {
    switch (data.position) {
      case "top-center":
        return "items-start justify-center"
      case "bottom-center":
        return "items-end justify-center"
      case "right-center":
        return "items-center justify-end"
      case "left-center":
        return "items-center justify-start"
      default:
        return "items-center justify-center"
    }
  }

  return (
    <div className={`absolute h-full w-full flex ${getPositionClasses()}`}>
      <ScaleFade visible={visible}>
        <div 
          style={data.style}
          className="m-2 p-3 bg-card text-card-foreground border font-roboto rounded-md shadow-md"
        >
          <div className="flex items-center gap-3">
            {data.icon && (
              <LibIcon
                icon={data.icon}
                fixedWidth
                size="lg"
                animation={data.iconAnimation}
                style={{
                  color: data.iconColor,
                  alignSelf:
                    !data.alignIcon || data.alignIcon === "center"
                      ? "center"
                      : "start"
                }}
              />
            )}
            <ReactMarkdown
              components={MarkdownComponents}
              remarkPlugins={[remarkGfm]}
            >
              {data.text}
            </ReactMarkdown>
          </div>
        </div>
      </ScaleFade>
    </div>
  )
}

export default TextUI
