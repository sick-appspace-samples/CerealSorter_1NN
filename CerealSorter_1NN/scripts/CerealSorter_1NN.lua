--[[----------------------------------------------------------------------------

  Application Name:
  CerealSorter_1NN

  Summary:
  Training a set of cereal types and classifying a test set.

  How to Run:
  Starting this sample is possible either by running the app (F5) or
  debugging (F7+F10). Setting breakpoint on the first row inside the 'main'
  function allows debugging step-by-step after 'Engine.OnStarted' event.
  Results can be seen in the image viewer on the DevicePage.
  Restarting the Sample may be necessary to show images after loading the webpage.
  To run this Sample a device with SICK Algorithm API and AppEngine >= V2.5.0 is
  required. For example SIM4000 with latest firmware. Alternatively the Emulator
  in AppStudio 2.3 or higher can be used.

  More Information:
  Tutorial "Algorithms - Cereal Sorter (1-NN)" and Tutorial "Algorithms - Machine Learning"

------------------------------------------------------------------------------]]
--Start of Global Scope---------------------------------------------------------

print('AppEngine Version: ' .. Engine.getVersion())

local DELAY = 1000 -- ms between visualization steps for demonstration purpose

-- Creating a viewer
local viewer = View.create("viewer2D1")

-- Setting up graphical overlay attributes
local textDecoration = View.TextDecoration.create()
textDecoration:setSize(35)
textDecoration:setPosition(25, 50)

local trainDecoration = View.ShapeDecoration.create()
trainDecoration:setLineColor(0, 0, 230) -- Blue

local testDecoration = View.ShapeDecoration.create()
testDecoration:setLineColor(0, 230, 0) -- Green

-- Training set
local cerealTypesTrain = {
  'Corn flakes',
  'Mixed crunch',
  'Muesli',
  'Oatmeal',
  'Rye crunch',
  'Strawberry crunch'
}

-- Test set
local cerealTypesTest = {
  'Oatmeal',
  'Strawberry crunch',
  'Mixed crunch',
  'Corn flakes',
  'Muesli',
  'Rye crunch'
}

-- Variable to hold histograms
local allTrainHistograms = {}

--End of Global Scope-----------------------------------------------------------

--Start of Function and Event Scope---------------------------------------------

local function createHistogram(img)
  -- Help function to concatenate histograms (as 1D-tables)
  local function tableConcat(t1, t2)
    for i = 1, #t2 do
      t1[#t1 + 1] = t2[i]
    end
    return t1
  end

  local H, S, V = img:toHSV()
  local histogramH, _ = H:getHistogram()
  local histogramS, _ = S:getHistogram()
  local histogramV, _ = V:getHistogram()
  local HS = tableConcat(histogramH, histogramS)
  local HSV = tableConcat(HS, histogramV) -- Concatenate H, S and V channels after one another
  return HSV
end

-- Training each cereal type by its histogram in HSV color space
local function train()
  for i = 1, #cerealTypesTrain do
    local img = Image.load('resources/Train/' .. tostring(i) .. '.bmp')
    viewer:clear()
    local imageID = viewer:addImage(img)
    viewer:addText( 'TEACH: ' .. tostring(cerealTypesTrain[i]), textDecoration, nil, imageID )
    viewer:present()
    Script.sleep(DELAY)

    -- Concatenate H, S and V channels after one another
    local HSV = createHistogram(img)
    allTrainHistograms[i] = HSV
  end
end

-- Classifying test set
local function classify()
  local classification = {} -- Array to store classification results

  for j = 1, #cerealTypesTest do
    local img = Image.load('resources/Test/' .. tostring(j) .. '.bmp')
    viewer:clear()
    local imageID = viewer:addImage(img)

    -- Concatenate H, S and V channels after one another
    local HSV = createHistogram(img)

    -- Comparing histogram of test image j with all training images
    local allHistogramDiffs = {} -- Array to store histogram comparisons
    for k = 1, #cerealTypesTrain do
      allHistogramDiffs[k] = Statistics.compareHistograms(HSV, allTrainHistograms[k])
      print(math.floor(allHistogramDiffs[k]))
    end

    -- Find the key of the smallest value from the histogram comparison array
    local key,
      min = 1, allHistogramDiffs[1]
    for k, v in ipairs(allHistogramDiffs) do
      if allHistogramDiffs[k] < min then
        key, min = k, v
      end
    end

    -- The key of the min comparison value equals the key of the cereal type in the training set
    classification[j] = cerealTypesTrain[key]
    print(classification[j])
    viewer:addText(tostring(classification[j]), textDecoration, nil, imageID)
    viewer:present()
    Script.sleep(DELAY)
  end
end

local function main()
  train()
  classify()
  print('App finished.')
end
Script.register('Engine.OnStarted', main)

--End of Function and Event Scope--------------------------------------------------
