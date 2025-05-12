import React, { useState } from "react"
import ReactMarkdown from "react-markdown"
import { useNuiEvent } from "../../hooks/useNuiEvent"
import { fetchNui } from "../../utils/fetchNui"
import { useLocales } from "../../providers/LocaleProvider"
import remarkGfm from "remark-gfm"
import MarkdownComponents from "../../config/MarkdownComponents"
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle
} from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"

const AlertDialog = () => {
  const { locale } = useLocales()
  const [opened, setOpened] = useState(false)
  const [dialogData, setDialogData] = useState({
    header: "",
    content: ""
  })

  const handleAlertClose = button => {
    setOpened(false)
    fetchNui("handleAlertClose", button)
  }

  useNuiEvent("sendAlert", data => {
    setDialogData(data)
    setOpened(true)
  })

  useNuiEvent("closeAlertDialog", () => {
    setOpened(false)
  })

  return (
    <Dialog
      open={opened}
      onOpenChange={open => {
        setOpened(open)
        if (!open) handleAlertClose("cancel")
      }}
    >
      <DialogContent
        className={`max-w-${dialogData.size ||
          "md"} bg-background border-border text-foreground ${
          dialogData.overflow ? "overflow-y-auto" : "overflow-hidden"
        } max-h-[90vh]`}
        onInteractOutside={e => e.preventDefault()}
      >
        <DialogHeader>
          <DialogTitle className="text-foreground">
            <ReactMarkdown components={MarkdownComponents}>
              {dialogData.header}
            </ReactMarkdown>
          </DialogTitle>
        </DialogHeader>
        <div className="flex flex-col gap-4 text-muted-foreground">
          <ReactMarkdown
            remarkPlugins={[remarkGfm]}
            components={{
              ...MarkdownComponents,
              img: ({ ...props }) => (
                <img
                  style={{ maxWidth: "100%", maxHeight: "100%" }}
                  {...props}
                />
              )
            }}
          >
            {dialogData.content}
          </ReactMarkdown>
          <div className="flex justify-end gap-2">
            {dialogData.cancel && (
              <Button
                variant="outline"
                onClick={() => handleAlertClose("cancel")}
                className="uppercase"
              >
                {dialogData.labels?.cancel || locale.interface.cancel}
              </Button>
            )}
            <Button
              variant={dialogData.cancel ? "secondary" : "outline"}
              onClick={() => handleAlertClose("confirm")}
              className="uppercase"
            >
              {dialogData.labels?.confirm || locale.interface.confirm}
            </Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  )
}

export default AlertDialog
