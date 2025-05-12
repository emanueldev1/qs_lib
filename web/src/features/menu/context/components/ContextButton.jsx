import { Button } from "@/components/ui/button"
import {
  HoverCard,
  HoverCardContent,
  HoverCardTrigger
} from "@/components/ui/hover-card"
import ReactMarkdown from "react-markdown"
import { fetchNui } from "../../../../utils/fetchNui"
import { isIconUrl } from "../../../../utils/isIconUrl"
import MarkdownComponents from "../../../../config/MarkdownComponents"
import LibIcon from "../../../../components/LibIcon"
import { cn } from "@/lib/utils"

const openMenu = id => {
  fetchNui("handleOpenContext", { id: id, back: false })
}

const handleClickContext = id => {
  fetchNui("handleClickContext", id)
}

const ContextButton = ({ option }) => {
  const button = option[1]
  const buttonKey = option[0]
  const isDisabled = button.disabled
  const isReadOnly = button.readOnly

  return (
    <HoverCard openDelay={200}>
      <HoverCardTrigger>
        <Button
          variant="outline"
          disabled={isDisabled}
          className={cn(
            "w-full justify-start h-auto p-2.5 !bg-background hover:text-foreground/80 hover:scale-105 transition-all",
            isDisabled && "text-muted-foreground",
            isReadOnly && "hover:bg-muted cursor-default active:transform-none"
          )}
          onClick={() => {
            if (!isDisabled && !isReadOnly) {
              button.menu ? openMenu(button.menu) : handleClickContext(buttonKey)
            }
          }}
        >
          <div className="flex items-center justify-between w-full gap-1">
            <div className="flex flex-col flex-1 gap-1">
              {(button.title || Number.isNaN(+buttonKey)) && (
                <div className="flex items-center gap-1">
                  {button?.icon && (
                    <div className="flex items-center justify-center w-[25px] h-[25px]">
                      {typeof button.icon === "string" &&
                      isIconUrl(button.icon) ? (
                        <img
                          src={button.icon}
                          alt="icon"
                          className="max-w-[25px]"
                        />
                      ) : (
                        <LibIcon
                          icon={button.icon}
                          fixedWidth
                          size="lg"
                          className={button.iconColor}
                          animation={button.iconAnimation}
                        />
                      )}
                    </div>
                  )}
                  <span className="break-words whitespace-pre-wrap">
                    <ReactMarkdown components={MarkdownComponents}>
                      {button.title || buttonKey}
                    </ReactMarkdown>
                  </span>
                </div>
              )}
              {button.description && (
                <span
                  className={cn(
                    "text-sm",
                    isDisabled
                      ? "text-muted-foreground/80"
                      : "text-muted-foreground"
                  )}
                >
                  <ReactMarkdown components={MarkdownComponents}>
                    {button.description}
                  </ReactMarkdown>
                </span>
              )}
              {button.progress !== undefined && (
                <div className="w-full h-1 bg-muted rounded-full overflow-hidden">
                  <div
                    className="h-full bg-muted-foreground transition-all"
                    style={{ width: `${button.progress}%` }}
                  />
                </div>
              )}
            </div>
            {(button.menu || button.arrow) && button.arrow !== false && (
              <div className="flex items-center justify-center w-[25px] h-[25px]">
                <LibIcon icon="chevron-right" fixedWidth />
              </div>
            )}
          </div>
        </Button>
      </HoverCardTrigger>
      {(button.metadata || button.image) && !isDisabled && (
        <HoverCardContent
          side="right"
          align="start"
          className="p-2.5 text-sm max-w-[256px] w-fit border-none"
        >
          {button.image && (
            <img src={button.image} alt="metadata" className="w-full" />
          )}
          {Array.isArray(button.metadata)
            ? button.metadata.map((metadata, index) => (
                <div key={`context-metadata-${index}`}>
                  <span>
                    {typeof metadata === "string"
                      ? metadata
                      : `${metadata.label}: ${metadata?.value ?? ""}`}
                  </span>
                  {typeof metadata === "object" &&
                    metadata.progress !== undefined && (
                      <div className="w-full h-1 bg-muted rounded-full overflow-hidden">
                        <div
                          className="h-full bg-muted-foreground transition-all"
                          style={{ width: `${metadata.progress}%` }}
                        />
                      </div>
                    )}
                </div>
              ))
            : typeof button.metadata === "object" &&
              Object.entries(button.metadata).map(([key, value], index) => (
                <span key={`context-metadata-${index}`}>
                  {key}: {value}
                </span>
              ))}
        </HoverCardContent>
      )}
    </HoverCard>
  )
}

export default ContextButton
