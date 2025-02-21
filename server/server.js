const express = require('express');
const soap = require('soap');
const http = require('http');

const app = express();

const service = {
  MyService: {
    MyPort: {
      AddNumbers: function (args) {
        const aValue = parseInt(args.a , 10);
        const bValue = parseInt(args.b , 10);
        console.log(' args.a + args.b',  aValue + bValue);
        return { result: aValue + bValue };
      },
    },
  },
};

const xml = `
<definitions name="MyService"
  targetNamespace="http://example.com/soap"
  xmlns="http://schemas.xmlsoap.org/wsdl/"
  xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/"
  xmlns:tns="http://example.com/soap"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema">

  <message name="AddNumbersRequest">
    <part name="a" type="xsd:int"/>
    <part name="b" type="xsd:int"/>
  </message>
  
  <message name="AddNumbersResponse">
    <part name="result" type="xsd:int"/>
  </message>

  <portType name="MyPort">
    <operation name="AddNumbers">
      <input message="tns:AddNumbersRequest"/>
      <output message="tns:AddNumbersResponse"/>
    </operation>
  </portType>

  <binding name="MyBinding" type="tns:MyPort">
    <soap:binding style="rpc" transport="http://schemas.xmlsoap.org/soap/http"/>
    <operation name="AddNumbers">
      <soap:operation soapAction="AddNumbers"/>
      <input>
        <soap:body use="encoded" encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"/>
      </input>
      <output>
        <soap:body use="encoded" encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"/>
      </output>
    </operation>
  </binding>

  <service name="MyService">
    <port name="MyPort" binding="tns:MyBinding">
      <soap:address location="http://localhost:8000/wsdl"/>
    </port>
  </service>
</definitions>
`;

const server = http.createServer(app);
server.listen(8000, () => {
  console.log('SOAP server running on http://localhost:8000/wsdl');
});

soap.listen(server, '/wsdl', service, xml);
