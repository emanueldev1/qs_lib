import { useNuiEvent } from "../../hooks/useNuiEvent"
import { toast, Toaster } from "react-hot-toast"
import ReactMarkdown from "react-markdown"
import React, { useState } from "react"
import tinycolor from "tinycolor2"
import MarkdownComponents from "../../config/MarkdownComponents"
import LibIcon from "../../components/LibIcon"

const createAnimation = (from, to, visible) => `
  @keyframes slide {
    from {
      opacity: ${visible ? 0 : 1};
      transform: translate${from};
    }
    to {
      opacity: ${visible ? 1 : 0};
      transform: translate${to};
    }
  }
  animation: slide ${
    visible ? "0.2s ease-out forwards" : "0.4s ease-in forwards"
  };
`

const getAnimation = (visible, position) => {
  let animation

  if (visible) {
    animation = position.includes("bottom")
      ? { from: "Y(30px)", to: "Y(0px)" }
      : { from: "Y(-30px)", to: "Y(0px)" }
  } else {
    if (position.includes("right")) {
      animation = { from: "X(0px)", to: "X(100%)" }
    } else if (position.includes("left")) {
      animation = { from: "X(0px)", to: "X(-100%)" }
    } else if (position === "top-center") {
      animation = { from: "Y(0px)", to: "Y(-100%)" }
    } else if (position === "bottom") {
      animation = { from: "Y(0px)", to: "Y(100%)" }
    } else {
      animation = { from: "X(0px)", to: "X(100%)" }
    }
  }

  return createAnimation(animation.from, animation.to, visible)
}

const Notifications = () => {
  const [toastKey, setToastKey] = useState(0)

  // useNuiEvent('notify', (data) => {
  useNuiEvent("notify", data => {
    if (!data.title && !data.description) return

    const toastId = data.id?.toString()
    const duration = data.duration || 3000
    let iconColor
    let position = data.position || "top-right"

    data.showDuration =
      data.showDuration !== undefined ? data.showDuration : true

    if (toastId) setToastKey(prevKey => prevKey + 1)

    // Compatibilidad con posiciones antiguas
    switch (position) {
      case "top":
        position = "top-center"
        break
      case "bottom":
        position = "bottom-center"
        break
    }

    // Ícono por defecto según tipo
    if (!data.icon) {
      switch (data.type) {
        case "error":
          data.icon = "circle-xmark"
          break
        case "success":
          data.icon = "circle-check"
          break
        case "warning":
          data.icon = "circle-exclamation"
          break
        default:
          data.icon = "circle-info"
          break
      }
    }

    // Color por defecto según tipo (usando HSL de shadcn/ui para dark mode)
    if (!data.iconColor) {
      switch (data.type) {
        case "error":
          iconColor = "hsl(0 84% 60%)" // shadcn red-500
          break
        case "success":
          iconColor = "hsl(173 58% 39%)" // shadcn teal-500
          break
        case "warning":
          iconColor = "hsl(43 96% 56%)" // shadcn yellow-500
          break
        default:
          iconColor = "hsl(221 83% 53%)" // shadcn blue-500
          break
      }
    } else {
      iconColor = tinycolor(data.iconColor).toHslString()
    }

    toast.custom(
      t => (
        <div
          className="w-[300px] bg-background border border-border rounded-lg shadow-lg p-2 font-sans text-foreground"
          style={{
            animation: getAnimation(t.visible, position),
            ...data.style
          }}
        >
          <div className="flex flex-col gap-1">
            {/* Contenido principal (ícono + texto) */}
            <div className="flex items-center gap-2">
              {data.icon && (
                <div
                  className="flex items-center justify-center w-6 h-6 rounded-full bg-muted"
                  style={{
                    backgroundColor: tinycolor(iconColor)
                      .setAlpha(0.1)
                      .toHslString()
                  }}
                >
                  <LibIcon
                    icon={data.icon}
                    fixedWidth
                    color={iconColor}
                    animation={data.iconAnimation}
                    className="w-4 h-4"
                  />
                </div>
              )}
              <div className="flex-1">
                {data.title && (
                  <span className="text-sm font-medium">{data.title}</span>
                )}
                {data.description && (
                  <ReactMarkdown
                    components={MarkdownComponents}
                    className={`${
                      !data.title ? "text-sm" : "text-xs"
                    } text-muted-foreground`}
                  >
                    {data.description}
                  </ReactMarkdown>
                )}
              </div>
            </div>

            {/* Progressbar en la parte inferior */}
            {data.showDuration && (
              <div className="w-full h-1 bg-muted rounded-full overflow-hidden mt-1">
                <div
                  className="h-full rounded-full transition-all duration-300 ease-linear"
                  style={{
                    width: "100%",
                    backgroundColor: iconColor,
                    animation: `progress-shrink ${duration}ms linear forwards`,
                    animationPlayState: t.visible ? "running" : "paused"
                  }}
                />
              </div>
            )}
          </div>
        </div>
      ),
      {
        id: toastId,
        duration: duration,
        position: position
      }
    )
  })

  return (
    <>
      <style>{`${progressShrinkAnimation}`}</style>
      <Toaster />
    </>
  )
}

const progressShrinkAnimation = `
  @keyframes progress-shrink {
    0% { width: 100%; }
    100% { width: 0%; }
  }
`

export default Notifications
