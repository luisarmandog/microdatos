dictionary  {
_column(001) str2 tipo_reg                       %2s   "tipo de registro                             "                       
_column(003) str2 cod_uf                         %2s   "código da uf                                 "                       
_column(005) str3 num_seq                        %3s   "número sequencial                            "                       
_column(008) str1 num_dv                         %1s   "dv do sequencial                             "                       
_column(009) str2 cod_domc                       %2s   "número do domicílio                          "        
_column(011) num_ext_renda                  %2g   "estrato geográfico                           	  	"       
_column(013) fator_expansao1                %14.8g  "fator de expansăo 1 (desenho amostral)       	  	"       
_column(027) fator_expansao2                %14.8g  "fator de expansăo 2 (ajustado p/ estimativas)	  	"       
_column(041) perd_cod_p_visit_realm_em      %4g   "período real da coleta                       	  	"       
_column(045) qtd_morador_domc               %4g   "quantidade de moradores                      	  	"       
_column(049) qtd_uc                         %2g   "quantidade de uc                             	  	"       
_column(051) qtd_familia                    %2g   "quantidade de famílias                       	  	"       
_column(053) cod_tipo_domc                  %2g   "tipo de domicilio                            	  	"       
_column(055) cod_material_parede            %2g   "material que predomina nas paredes externas  	  	"       
_column(057) cod_material_cobertura         %2g   "material que predomina na cobertura          	  	"       
_column(059) cod_material_piso              %2g   "material que predomina no piso               	  	"       
_column(061) qtd_comodos_domc               %2g   "quantidade de cômodos                        	  	"       
_column(063) qtd_comd_serv_dormit           %2g   "cômodos servindo de dormitório               	  	"       
_column(065) cod_agua_comodo                %2g   "existęncia de água canalizada                	  	"       
_column(067) cod_abast_agua                 %2g   "provenięncia da água                         	  	"       
_column(069) qtd_banheiros                  %2g   "quantidade de banheiros                      	  	"       
_column(071) cod_esgoto_sanit               %2g   "escoadouro sanitário                         	  	"       
_column(073) cod_cond_ocup                  %2g   "condiçăo de ocupaçăo                         	  	"       
_column(075) cod_tempo_moradia              %2g   "tempo de aluguel                             	  	"       
_column(077) cod_contrato_docum             %2g   "tipo de contrato de aluguel                  	  	"       
_column(079) cod_exist_pavim                %2g   "existęncia de pavimentaçăo na rua            	  	"       
_column(081) imput_qtd_comodos              %1g   "imputaçăo - quantidade de cômodos                    	"       
_column(082) imput_qtd_banheiros            %1g   "imputaçăo - quantidade de banheiros                  	"       
_column(083) imput_esgoto                   %1g   "imputaçăo - escoadouro sanitário                     	"       
_column(084) renda_bruta_monetaria          %16.2g  "renda monetária mensal do domicílio                  	"       
_column(100) renda_bruta_nao_monetaria      %16.2g  "renda năo monetária mensal do domicílio                  	"       
_column(116) renda_total                    %16.2g  "renda total mensal do domicílio                          	"       
_column(132) cod_servico_distribuicao       %1g   "serviço de distribuiçăo dos correios                     	"       
_column(133) estrada_grande_1               %1g   "proximidade a estrada de grande circulaçăo de veículos   	"       
_column(134) area_1                         %1g   "proximidade a área industrial                            	"       
_column(135) estrada_ferro_1                %1g   "proximidade a estrada de ferro em uso                    	"       
_column(136) passagem_1                     %1g   "proximidade a passagem de fios de alta tensăo            	"       
_column(137) gasoduto_1                     %1g   "proximidade a gasoduto ou oleoduto                       	"       
_column(138) lixao_1                        %1g   "proximidade a lixăo ou depósito de lixo                	"       
_column(139) esgoto_1                       %1g   "proximidade a esgoto a céu aberto ou valăo               	"       
_column(140) rio_1                          %1g   "proximidade a rio, baía, lago, açude ou represa poluídos 	"       
_column(141) encosta_1                      %1g   "proximidade a encosta ou área sujeita a deslizamento     	"       
_column(142) lixo_biodegradavel             %1g   "separaçăo do lixo 						"       
_column(143) lixo_separado                  %1g   "finalidade da separaçăo do lixo 				"       
_column(144) cod_lixo                       %2g   "destino do lixo                                            "       
_column(146) rede_15                        %1g   "rede geral de energia elétrica                             "       
_column(147) propria_15                     %1g   "fonte própria para energia elétrica                        "       
_column(148) diesel_16                      %1g   "diesel/gasolina/gás para energia elétrica                  "       
_column(149) solar_16                       %1g   "energia solar para energia elétrica                        "       
_column(150) eolica_16                      %1g   "energia eólica para energia elétrica          	 	"       
_column(151) agua_16                        %1g   "água para energia elétrica      			        "       
_column(152) biodiesel_16                   %1g   "biodiesel para energia elétrica             	        "       
_column(153) sistema_misto_16               %1g   "sistema misto para energia elétrica         	        "       
_column(154) outra_fonte_16                 %1g   "outra fonte para energia elétrica                          "       
_column(155) energia_17                     %1g   "aquecimento de água por energia elétrica           	"       
_column(156) gas_17                         %1g   "aquecimento de água por gás            			"       
_column(157) energia_solar_17               %1g   "aquecimento de água por energia solar             		"       
_column(158) lenha_17                       %1g   "aquecimento de água por lenha/carvăo 	      		"       
_column(159) outra_forma_17                 %1g   "aquecimento de água por outra fonte 		        "       
_column(160) gas_18                         %1g   "fogăo a gás                				"       
_column(161) lenha_18                       %1g   "fogăo a lenha                                              "       
_column(162) carvao_18                      %1g   "fogăo a carvăo                                             "       
_column(163) energia_eletrica_18            %1g   "fogăo a energia elétrica                                   "       
_column(164) outro_18                       %1g   "fogăo com outra fonte                                      "
}
