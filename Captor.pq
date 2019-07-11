// This file contains your Data Connector logic
section Captor;

[DataSource.Kind="Captor", Publish="Captor.Publish"]
shared Captor.Contents = Value.ReplaceType(Captor.Implementation, Captor.Type);

Captor.Type = type function (
    CaptorURL as (type text meta [
        Documentation.FieldCaption = "Captor Webservice URL",
        Documentation.FieldDescription = "Captor Webservice URL",
        Documentation.SampleValues = {"http://<HOSTNAME>/Captor3/WebServices/Public/CustomWorkplaceData.asmx"}
    ]),
    CaptorUser as (type text meta [
        Documentation.FieldCaption = "Username",
        Documentation.FieldDescription = "Captor Username"
        
    ]),
    CaptorPwd as (type text meta [
        Documentation.FieldCaption = "Password",
        Documentation.FieldDescription = "Captor Password"
        
    ]),
    CaptorCenter as (type text meta [
        Documentation.FieldCaption = "Company",
        Documentation.FieldDescription = "Captor Company"
        
    ]),
    CaptorWP as (type text meta [
        Documentation.FieldCaption = "Workplace",
        Documentation.FieldDescription = "Captor Workplace"
        
    ]),
    CaptorWS as (type text meta [
        Documentation.FieldCaption = "Webservice Action",
        Documentation.FieldDescription = "WebService Action",
        Documentation.AllowedValues = { "GetCurrentWorkplaceGroupState", "GetCurrentWorkplaceHistory","GetCurrentWorkplaceKpis", "GetCurrentWorkplaceManufacturingPhases","GetCurrentWorkplaceState","GetCurrentWorkplaceWorkers"}
    ]))
    as table meta [
        Documentation.Name = "Captor",
        Documentation.LongDescription = "Captor SOAP connector"
    ];

Captor.Implementation = (CaptorURL as text , CaptorUser as text, CaptorPwd as text, CaptorCenter as text, CaptorWP as text, CaptorWS as text) as table  =>
    let
        envelope = GetAction(CaptorURL,GetsessionId(CaptorURL,CaptorUser,CaptorPwd,CaptorCenter),CaptorWP, CaptorWS)
    in
        envelope;

        
GetsessionId  = (site as text, captoruser as text, captorpwd as text, captorcenter as text) =>
    let envelope = Xml.Document(Web.Contents(site,
    [Headers= [#"Content-Type"= "application/soap+xml;charset=utf-8",#"SOAPAction"= "http://sisteplant.com/InitSession"],
    Content = Text.ToBinary("<?xml version="&Character.FromNumber(34)&"1.0"&Character.FromNumber(34)&" encoding="&Character.FromNumber(34)&"utf-8"&Character.FromNumber(34)&"?><soap12:Envelope xmlns:xsi="&Character.FromNumber(34)&"http://www.w3.org/2001/XMLSchema-instance"&Character.FromNumber(34)&" xmlns:xsd="&Character.FromNumber(34)&"http://www.w3.org/2001/XMLSchema"&Character.FromNumber(34)&" xmlns:soap12="&Character.FromNumber(34)&"http://www.w3.org/2003/05/soap-envelope"&Character.FromNumber(34)&"><soap12:Body><InitSession xmlns="&Character.FromNumber(34)&"http://sisteplant.com/"&Character.FromNumber(34)&"><user>"&captoruser&"</user><password>"&captorpwd&"</password><company>"&captorcenter&"</company></InitSession></soap12:Body></soap12:Envelope>")
    ])),
    Value = envelope{0}[Value],
    Value1 = Value{0}[Value],
    Value2 = Value1{0}[Value],
    source = Table.FirstValue(Table.SelectColumns(Value2,{"Value"}))
    in
        source;

Closesession = (site as text, sessionid as text) =>
    let source = Xml.Document(Web.Contents(site,
    [Headers= [#"Content-Type"= "application/soap+xml;charset=utf-8",#"SOAPAction"= "http://sisteplant.com/CloseSession"],
    Content = Text.ToBinary("<?xml version="&Character.FromNumber(34)&"1.0"&Character.FromNumber(34)&" encoding="&Character.FromNumber(34)&"utf-8"&Character.FromNumber(34)&"?><soap12:Envelope xmlns:xsi="&Character.FromNumber(34)&"http://www.w3.org/2001/XMLSchema-instance"&Character.FromNumber(34)&" xmlns:xsd="&Character.FromNumber(34)&"http://www.w3.org/2001/XMLSchema"&Character.FromNumber(34)&" xmlns:soap12="&Character.FromNumber(34)&"http://www.w3.org/2003/05/soap-envelope"&Character.FromNumber(34)&"><soap12:Body><CloseSession xmlns="&Character.FromNumber(34)&"http://sisteplant.com/"&Character.FromNumber(34)&"><sessionId>" & sessionid  & "</sessionId></CloseSession></soap12:Body></soap12:Envelope>")
    ]))
    in
        source;

GetAction  = (site as text, sessionid as text ,captorwp as text, captorws as text) =>
    let envelope = Xml.Tables(Web.Contents(site,
    [Headers= [#"Content-Type"= "application/soap+xml;charset=utf-8",#"SOAPAction"= "http://sisteplant.com/" & captorws],
    Content = Text.ToBinary("<?xml version="&Character.FromNumber(34)&"1.0"&Character.FromNumber(34)&" encoding="&Character.FromNumber(34)&"utf-8"&Character.FromNumber(34)&"?><soap12:Envelope xmlns:xsi="&Character.FromNumber(34)&"http://www.w3.org/2001/XMLSchema-instance"&Character.FromNumber(34)&" xmlns:xsd="&Character.FromNumber(34)&"http://www.w3.org/2001/XMLSchema"&Character.FromNumber(34)&" xmlns:soap12="&Character.FromNumber(34)&"http://www.w3.org/2003/05/soap-envelope"&Character.FromNumber(34)&"><soap12:Body><" & captorws & " xmlns="&Character.FromNumber(34)&"http://sisteplant.com/"&Character.FromNumber(34)&"><sessionId>" & sessionid & "</sessionId><workplace>" & captorwp  & "</workplace></" & captorws &"></soap12:Body></soap12:Envelope>")
    ])),
    Table = envelope{0}[Table],
    Table1 = Table{0}[Table],
    Table2 = Table1{0}[Table],
    source = Table2{0}[Table]
    in
        source;



// Data Source Kind description
Captor = [
    TestConnection = (dataSourcePath) =>
        let
            json = Json.Document(dataSourcePath),
            CaptorURL = json[CaptorURL],
            CaptorUser = json[CaptorUser],
            CaptorPwd = json[CaptorPwd],
            CaptorCenter = json[CaptorCenter],
            CaptorWP = json[CaptorWP]
        in
            { "Captor.Contents", CaptorURL , CaptorUser, CaptorPwd, CaptorCenter, CaptorWP },
    
    Authentication = [
         Anonymous = []
    ],
    Label = Extension.LoadString("DataSourceLabel")
];

// Data Source UI publishing description
Captor.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = Captor.Icons,
    SourceTypeImage = Captor.Icons
];

Captor.Icons = [
    Icon16 = { Extension.Contents("Captor16.png"), Extension.Contents("Captor20.png"), Extension.Contents("Captor24.png"), Extension.Contents("Captor32.png") },
    Icon32 = { Extension.Contents("Captor32.png"), Extension.Contents("Captor40.png"), Extension.Contents("Captor48.png"), Extension.Contents("Captor64.png") }
];
