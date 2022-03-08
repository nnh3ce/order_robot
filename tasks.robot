*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.RobotLogListener
Library           RPA.PDF
Library           RPA.Archive
Library           OperatingSystem
Library           RPA.Dialogs
Library           Dialogs
Library           RPA.Robocorp.Vault

*** Tasks ***
Orders robots from RobotSpareBin Industries Inc.
    Create folder to be zipped
    Download csv file
    Open order website
    Click ok button
    Fill order form
    Zip the folder

*** Keywords ***
Download csv file
    ${file_to_upload}=    Get Value From User    Please provide the url of the csv file to upload: https://robotsparebinindustries.com/orders.csv
    Download    ${file_to_upload}    ${OUTPUT_DIR}${/}orders.csv
    #https://robotsparebinindustries.com/orders.csv

Create folder to be zipped
    Create Directory    ${OUTPUT_DIR}${/}to_be_zipped_archive

Submit order form
    Set Local Variable    ${order_btn}    id:order
    Set Local Variable    ${lbl_receipt}    id:receipt
    Mute Run On Failure    Page Should Contain Element
    Click Button    ${order_btn}
    Page Should Contain Element    ${lbl_receipt}

Fill form with csv data for one order
    [Arguments]    ${order}
    Select From List By Index    id:head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    xpath://input[@type="number"]    ${order}[Legs]
    Input Text    id:address    ${order}[Address]
    Click Button    id:preview
    Wait Until Keyword Succeeds    10x    2s    Submit order form
    Wait Until Element Is Visible    id:order-another
    ${robot_image}=    Take screenshot    ${order}[Order number]
    ${receipt}=    Store receipt as pdf
    ${final_pdf}=    Embed screenshot    ${robot_image}    ${receipt}    ${order}[Order number]
    #zip final pdf here
    Click Element When Visible    id:order-another
    Click ok button

Fill order form
    ${csv_table}=    Read table from CSV    ${OUTPUT_DIR}${/}orders.csv    header:True
    FOR    ${order}    IN    @{csv_table}
        Fill form with csv data for one order    ${order}
    END

Open order website
    #Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    ${url}=    Get Secret    website
    Open Available Browser    ${url}[orders]

Click ok button
    Click Button When Visible    class:btn-dark

Store receipt as pdf
    ${order_no}=    Get Text    class:badge-success
    Wait Until Element Is Visible    id:receipt
    ${receipt}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt}    ${OUTPUT_DIR}${/}to_be_zipped_archive${/}${order_no}.pdf
    [Return]    ${OUTPUT_DIR}${/}to_be_zipped_archive${/}${order_no}.pdf

Take screenshot
    [Arguments]    ${order_no}
    ${image}=    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}to_be_zipped_archive${/}${order_no}image.png
    [Return]    ${OUTPUT_DIR}${/}to_be_zipped_archive${/}${order_no}image.png

Embed screenshot
    [Arguments]    ${robot_image}    ${receipt}    ${order_no}
    ${pdf_file_list}=    Create List    ${robot_image}    ${receipt}
    Add Files To Pdf    ${pdf_file_list}    ${OUTPUT_DIR}${/}${order_no}.pdf    #append:true

Zip the folder
    Archive Folder With Zip    ${OUTPUT_DIR}${/}to_be_zipped_archive    orders.zip
