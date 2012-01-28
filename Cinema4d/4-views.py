"""
Export 4 view render

(C) Kimchi and Chips 2012
"""

import c4d

path = ''
pathToOutput = ''
index = 0
doc = c4d.documents.GetActiveDocument()
rdata = doc.GetActiveRenderData()
batch = 0
baseDraw = 0

def setFilenames(trunk):
    rdata[c4d.RDATA_PATH] = pathToOutput + trunk
    rdata[c4d.RDATA_MULTIPASS_FILENAME] = pathToOutput + trunk

def setResolution(wide):
    xRes = 1024
    if (wide):
        xRes = 2048
    rdata[c4d.RDATA_XRES] = xRes
    rdata[c4d.RDATA_YRES] = 1024

def setCamera(name):
    print 'camera = ' + name
    camera = doc.SearchObject(name)
    baseDraw.SetSceneCamera(camera, True)

def addRender(name):
    global index
    output = pathToOutput + name + '.c4d'
    print 'saving: ' + output
    c4d.documents.SaveDocument(doc, output, c4d.SAVEDOCUMENTFLAGS_0, c4d.FORMAT_C4DEXPORT)
    batch.AddFile(output, index)
    index += 1

def render(name):
    setFilenames(name)
    wide = (name == 'front') | (name == 'back')
    setResolution(wide)
    setCamera(name)
    addRender(name)

def main():
    global doc
    global path
    global pathToOutput
    global batch
    global baseDraw
    global index

    # Get the current doc
    doc = c4d.documents.GetActiveDocument()

    # Get the current active render settings
    rdata = doc.GetActiveRenderData()
    
    # Get the current path
    path = doc.GetDocumentPath()
    pathToOutput = path + '\\Output\\'

    # Get the batch renderer
    batch = c4d.documents.GetBatchRender()

    # Get the current base draw
    baseDraw = doc.GetActiveBaseDraw() # The editor camera

    # Add the renders
    index = 0
    render('front')
    render('back')
    render('left')
    render('right')

    # Open the batch queue
    batch.Open()
    batch.SetRendering(c4d.BR_START)

    # Send global event message to update the RenderSettings dialog
    c4d.EventAdd()

if __name__=='__main__':
    main()
