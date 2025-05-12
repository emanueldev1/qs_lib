import React, { useState } from "react"
import { debugAlert } from "./debug/alert"
import { debugContext } from "./debug/context"
import { debugInput } from "./debug/input"
import { debugMenu } from "./debug/menu"
import { debugCustomNotification } from "./debug/notification"
import { debugCircleProgressbar, debugProgressbar } from "./debug/progress"
import { debugTextUI } from "./debug/textui"
import { debugSkillCheck } from "./debug/skillcheck"
import { debugRadial } from "./debug/radial"
import LibIcon from "../../components/LibIcon"
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle
} from "@/components/ui/sheet"
import { Button } from "@/components/ui/button"
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger
} from "@/components/ui/tooltip"

const Dev = () => {
  const [opened, setOpened] = useState(false)

  return (
    <>
      <TooltipProvider>
        <Tooltip>
          <TooltipTrigger asChild>
            <Button
              onClick={() => setOpened(true)}
              variant="default"
              size="icon"
              className="fixed bottom-4 right-4 w-12 h-12 rounded-full bg-orange-500 hover:bg-orange-600 text-white mr-12 mb-12"
            >
              <LibIcon icon="wrench" className="w-6 h-6" />
            </Button>
          </TooltipTrigger>
          <TooltipContent side="bottom">
            <p>Developer drawer</p>
          </TooltipContent>
        </Tooltip>
      </TooltipProvider>

      <Sheet open={opened} onOpenChange={setOpened}>
        <SheetContent
          side="left"
          className="bg-background text-foreground w-[300px] sm:w-[300px] p-0"
        >
          <SheetHeader className="p-4">
            <SheetTitle className="text-lg font-medium">
              Developer drawer
            </SheetTitle>
          </SheetHeader>
          <div className="flex flex-col gap-2 p-4">
            <hr className="border-border" />
            <Button
              onClick={() => debugInput()}
              variant="outline"
              className="w-full"
            >
              Open input dialog
            </Button>
            <Button
              onClick={() => debugAlert()}
              variant="outline"
              className="w-full"
            >
              Open alert dialog
            </Button>
            <hr className="border-border" />
            <Button
              onClick={() => debugContext()}
              variant="outline"
              className="w-full"
            >
              Open context menu
            </Button>
            <Button
              onClick={() => debugMenu()}
              variant="outline"
              className="w-full"
            >
              Open list menu
            </Button>
            <Button
              onClick={() => debugRadial()}
              variant="outline"
              className="w-full"
            >
              Open radial menu
            </Button>
            <hr className="border-border" />
            <Button
              onClick={() => debugCustomNotification()}
              variant="outline"
              className="w-full"
            >
              Send notification
            </Button>
            <hr className="border-border" />
            <Button
              onClick={() => debugProgressbar()}
              variant="outline"
              className="w-full"
            >
              Activate progress bar
            </Button>
            <Button
              onClick={() => debugCircleProgressbar()}
              variant="outline"
              className="w-full"
            >
              Activate progress circle
            </Button>
            <hr className="border-border" />
            <Button
              onClick={() => debugTextUI()}
              variant="outline"
              className="w-full"
            >
              Show TextUI
            </Button>
            <hr className="border-border" />
            <Button
              onClick={() => debugSkillCheck()}
              variant="outline"
              className="w-full"
            >
              Run skill check
            </Button>
          </div>
        </SheetContent>
      </Sheet>
    </>
  )
}

export default Dev
