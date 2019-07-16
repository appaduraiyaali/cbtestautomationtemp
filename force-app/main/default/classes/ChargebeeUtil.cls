public with sharing class ChargebeeUtil{

    public static String[] zeroDecimalCurrencies = new String[]{'JPY', //Japanese Yen
                'KRW', //South Korean Won
                'BIF', //Burundian Franc
                'DJF', //Djiboutian Franc
                'PYG', //Paraguayan Guaraní
                'VND', //Vietnamese Đồng
                'CLP', //Chilean Peso
                'GNF', //Guinean Franc
                'RWF', //Rwandan Franc
                'VUV', //Vanuatu Vatu
                'XAF', //CFA franc BEAC
                'XOF', //CFA Franc BCEAO
                'XPF', //CFP franc 
                'MGA', //Malagasy ariary
                'KMF', //Comorian franc
                'ALL', //Albanian Lek
                'BYR' //Belarussian ruble
                };
                
    public static List<SelectOption> getCountrySelectOptions(){
        List<SelectOption> optionsCountry = new List<SelectOption>();
        optionsCountry.add(new SelectOption('-1','Select your country'));
        
        Map<String, String> countryMap = getCountryMap();
        for(String key : countryMap.keySet()){
            optionsCountry.add(new SelectOption(key,countryMap.get(key)));
        }
        return optionsCountry;
    }
    
    //gets country code for country name
    public static String getCountryCode(String country){
        Map<String, String> countryMap = getCountryMap();
        
        for(String key : countryMap.keySet()){
            if( key.equalsIgnoreCase(country) || countryMap.get(key).equalsIgnoreCase(country)){
                return key;
            }
        }
        return country;
    }
    
    //converts to higher level of currency. eg. converts Cents to USD
    public static Double convertToHigherOrderCurrency(String cbCurrencyCode, long amount) {
        return zeroDecimalCurrencies.contains(cbCurrencyCode)?amount:(amount/100.0);
    }
    
    //converts to lower level of currency. eg. converts USD to Cents 
    public static integer convertToLowerOrderCurrency(String currencyCode, Double amt){
        return (zeroDecimalCurrencies.contains(currencyCode)?amt:(amt*100.0)).intValue();
    }
    
    public static Map<String, String> getCountryMap(){
        Map<String,String> countryMap = new Map<String,String>();
        countryMap.put('AF','Afghanistan');
        countryMap.put('AX','Aland Islands');
        countryMap.put('AL','Albania');
        countryMap.put('DZ','Algeria');
        countryMap.put('AS','American Samoa');
        countryMap.put('AD','Andorra');
        countryMap.put('AO','Angola');
        countryMap.put('AI','Anguilla');
        countryMap.put('AQ','Antarctica');
        countryMap.put('AG','Antigua And Barbuda');
        countryMap.put('AR','Argentina');
        countryMap.put('AM','Armenia');
        countryMap.put('AW','Aruba');
        countryMap.put('AU','Australia');
        countryMap.put('AT','Austria');
        countryMap.put('AZ','Azerbaijan');
        countryMap.put('BS','Bahamas');
        countryMap.put('BH','Bahrain');
        countryMap.put('BD','Bangladesh');
        countryMap.put('BB','Barbados');
        countryMap.put('BY','Belarus');
        countryMap.put('BE','Belgium');
        countryMap.put('BZ','Belize');
        countryMap.put('BJ','Benin');
        countryMap.put('BM','Bermuda');
        countryMap.put('BT','Bhutan');
        countryMap.put('BO','Bolivia');
        countryMap.put('BA','Bosnia And Herzegovina');
        countryMap.put('BW','Botswana');
        countryMap.put('BV','Bouvet Island');
        countryMap.put('BR','Brazil');
        countryMap.put('IO','British Indian Ocean Territory');
        countryMap.put('VG','British Virgin Islands');
        countryMap.put('BN','Brunei Darussalam');
        countryMap.put('BG','Bulgaria');
        countryMap.put('BF','Burkina Faso');
        countryMap.put('BI','Burundi');
        countryMap.put('KH','Cambodia');
        countryMap.put('CM','Cameroon');
        countryMap.put('CA','Canada');
        countryMap.put('CV','Cape Verde');
        countryMap.put('KY','Cayman Islands');
        countryMap.put('CF','Central African Republic');
        countryMap.put('TD','Chad');
        countryMap.put('CL','Chile');
        countryMap.put('CN','China');
        countryMap.put('CX','Christmas Island');
        countryMap.put('CC','Cocos (Keeling) Islands');
        countryMap.put('CO','Colombia');
        countryMap.put('KM','Comoros');
        countryMap.put('CG','Congo');
        countryMap.put('CD','Congo (Democratic Republic)');
        countryMap.put('CK','Cook Islands');
        countryMap.put('CR','Costa Rica');
        countryMap.put('CI','Côte D\'ivoire');
        countryMap.put('HR','Croatia');
        countryMap.put('CW','Curaçao');
        countryMap.put('CU','Cuba');
        countryMap.put('CY','Cyprus');
        countryMap.put('CZ','Czech Republic');
        countryMap.put('DK','Denmark');
        countryMap.put('DJ','Djibouti');
        countryMap.put('DM','Dominica');
        countryMap.put('DO','Dominican Republic');
        countryMap.put('EC','Ecuador');
        countryMap.put('EG','Egypt');
        countryMap.put('SV','El Salvador');
        countryMap.put('GQ','Equatorial Guinea');
        countryMap.put('ER','Eritrea');
        countryMap.put('EE','Estonia');
        countryMap.put('ET','Ethiopia');
        countryMap.put('FK','Falkland Islands (Malvinas)');
        countryMap.put('FO','Faroe Islands');
        countryMap.put('FJ','Fiji');
        countryMap.put('FI','Finland');
        countryMap.put('FR','France');
        countryMap.put('GF','French Guiana');
        countryMap.put('PF','French Polynesia');
        countryMap.put('TF','French Southern Territories');
        countryMap.put('GA','Gabon');
        countryMap.put('GM','Gambia');
        countryMap.put('GE','Georgia');
        countryMap.put('DE','Germany');
        countryMap.put('GH','Ghana');
        countryMap.put('GI','Gibraltar');
        countryMap.put('GR','Greece');
        countryMap.put('GL','Greenland');
        countryMap.put('GD','Grenada');
        countryMap.put('GP','Guadeloupe');
        countryMap.put('GU','Guam');
        countryMap.put('GT','Guatemala');
        countryMap.put('GG','Guernsey');
        countryMap.put('GN','Guinea');
        countryMap.put('GW','Guinea-bissau');
        countryMap.put('GY','Guyana');
        countryMap.put('HT','Haiti');
        countryMap.put('HM','Heard Island And Mcdonald Islands');
        countryMap.put('HN','Honduras');
        countryMap.put('HK','Hong Kong');
        countryMap.put('HU','Hungary');
        countryMap.put('IS','Iceland');
        countryMap.put('IN','India');
        countryMap.put('ID','Indonesia');
        countryMap.put('IR','Iran');
        countryMap.put('IQ','Iraq');
        countryMap.put('IE','Ireland');
        countryMap.put('IM','Isle Of Man');
        countryMap.put('IL','Israel');
        countryMap.put('IT','Italy');
        countryMap.put('JM','Jamaica');
        countryMap.put('JP','Japan');
        countryMap.put('JE','Jersey');
        countryMap.put('JO','Jordan');
        countryMap.put('KZ','Kazakhstan');
        countryMap.put('KE','Kenya');
        countryMap.put('KI','Kiribati');
        countryMap.put('KP','Korea (Democratic People\'s Republic)');
        countryMap.put('KR','Korea (Republic)');
        countryMap.put('KW','Kuwait');
        countryMap.put('KG','Kyrgyzstan');
        countryMap.put('LA','Lao (People\'s Democratic Republic)');
        countryMap.put('LV','Latvia');
        countryMap.put('LB','Lebanon');
        countryMap.put('LS','Lesotho');
        countryMap.put('LR','Liberia');
        countryMap.put('LY','Libya');
        countryMap.put('LI','Liechtenstein');
        countryMap.put('LT','Lithuania');
        countryMap.put('LU','Luxembourg');
        countryMap.put('MO','Macao');
        countryMap.put('MK','Macedonia');
        countryMap.put('MG','Madagascar');
        countryMap.put('MW','Malawi');
        countryMap.put('MY','Malaysia');
        countryMap.put('MV','Maldives');
        countryMap.put('ML','Mali');
        countryMap.put('MT','Malta');
        countryMap.put('MH','Marshall Islands');
        countryMap.put('MQ','Martinique');
        countryMap.put('MR','Mauritania');
        countryMap.put('MU','Mauritius');
        countryMap.put('YT','Mayotte');
        countryMap.put('MX','Mexico');
        countryMap.put('FM','Micronesia');
        countryMap.put('MD','Moldova');
        countryMap.put('MC','Monaco');
        countryMap.put('MN','Mongolia');
        countryMap.put('ME','Montenegro');
        countryMap.put('MS','Montserrat');
        countryMap.put('MA','Morocco');
        countryMap.put('MZ','Mozambique');
        countryMap.put('MM','Myanmar');
        countryMap.put('NA','Namibia');
        countryMap.put('NR','Nauru');
        countryMap.put('NP','Nepal');
        countryMap.put('NL','Netherlands');
        countryMap.put('NC','New Caledonia');
        countryMap.put('NZ','New Zealand');
        countryMap.put('NI','Nicaragua');
        countryMap.put('NE','Niger');
        countryMap.put('NG','Nigeria');
        countryMap.put('NU','Niue');
        countryMap.put('NF','Norfolk Island');
        countryMap.put('MP','Northern Mariana Islands');
        countryMap.put('NO','Norway');
        countryMap.put('OM','Oman');
        countryMap.put('PK','Pakistan');
        countryMap.put('PW','Palau');
        countryMap.put('PS','Palestinian Territory (Occupied)');
        countryMap.put('PA','Panama');
        countryMap.put('PG','Papua New Guinea');
        countryMap.put('PY','Paraguay');
        countryMap.put('PE','Peru');
        countryMap.put('PH','Philippines');
        countryMap.put('PN','Pitcairn');
        countryMap.put('PL','Poland');
        countryMap.put('PT','Portugal');
        countryMap.put('PR','Puerto Rico');
        countryMap.put('QA','Qatar');
        countryMap.put('RE','Reunion');
        countryMap.put('RO','Romania');
        countryMap.put('RU','Russian Federation');
        countryMap.put('RW','Rwanda');
        countryMap.put('BL','Saint Barthélemy');
        countryMap.put('SH','Saint Helena');
        countryMap.put('KN','Saint Kitts And Nevis');
        countryMap.put('LC','Saint Lucia');
        countryMap.put('MF','Saint Martin (French Part)');
        countryMap.put('PM','Saint Pierre And Miquelon');
        countryMap.put('VC','Saint Vincent And The Grenadines');
        countryMap.put('WS','Samoa');
        countryMap.put('SM','San Marino');
        countryMap.put('ST','Sao Tome And Principe');
        countryMap.put('SA','Saudi Arabia');
        countryMap.put('SN','Senegal');
        countryMap.put('RS','Serbia');
        countryMap.put('SC','Seychelles');
        countryMap.put('SL','Sierra Leone');
        countryMap.put('SG','Singapore');
        countryMap.put('BQ','Sint Eustatius And Saba Bonaire');
        countryMap.put('SX','Sint Maarten (Dutch Part)');
        countryMap.put('SK','Slovakia');
        countryMap.put('SI','Slovenia');
        countryMap.put('SB','Solomon Islands');
        countryMap.put('SO','Somalia');
        countryMap.put('ZA','South Africa');
        countryMap.put('GS','South Georgia And The South Sandwich Islands');
        countryMap.put('SS','South Sudan');
        countryMap.put('ES','Spain');
        countryMap.put('LK','Sri Lanka');
        countryMap.put('SD','Sudan');
        countryMap.put('SR','Suriname');
        countryMap.put('SJ','Svalbard And Jan Mayen');
        countryMap.put('SZ','Swaziland');
        countryMap.put('SE','Sweden');
        countryMap.put('CH','Switzerland');
        countryMap.put('SY','Syrian Arab Republic');
        countryMap.put('TW','Taiwan');
        countryMap.put('TJ','Tajikistan');
        countryMap.put('TZ','Tanzania');
        countryMap.put('TH','Thailand');
        countryMap.put('TL','Timor-leste');
        countryMap.put('TG','Togo');
        countryMap.put('TK','Tokelau');
        countryMap.put('TO','Tonga');
        countryMap.put('TT','Trinidad And Tobago');
        countryMap.put('TN','Tunisia');
        countryMap.put('TR','Turkey');
        countryMap.put('TM','Turkmenistan');
        countryMap.put('TC','Turks And Caicos Islands');
        countryMap.put('TV','Tuvalu');
        countryMap.put('UG','Uganda');
        countryMap.put('UA','Ukraine');
        countryMap.put('AE','United Arab Emirates');
        countryMap.put('GB','United Kingdom');
        countryMap.put('US','United States');
        countryMap.put('UM','United States Minor Outlying Islands');
        countryMap.put('UY','Uruguay');
        countryMap.put('UZ','Uzbekistan');
        countryMap.put('VU','Vanuatu');
        countryMap.put('VA','Vatican City');
        countryMap.put('VE','Venezuela');
        countryMap.put('VN','Viet Nam');
        countryMap.put('VI','U.S. Virgin Islands');
        countryMap.put('WF','Wallis And Futuna');
        countryMap.put('EH','Western Sahara');
        countryMap.put('YE','Yemen');
        countryMap.put('ZM','Zambia');
        countryMap.put('ZW','Zimbabwe');
        return countryMap;
    }
}