Procedure IM_LeeTexto(VNOMBREarchivo varchar) Is
	in_file   CLIENT_TEXT_IO.FILE_TYPE; --in_file   TEXT_IO.FILE_TYPE;
	linebuf   VARCHAR2 (1000);
	n       number(7);
	vOrden PlanillaTerceros.Orden%Type;
	nNumeroCuenta PlanillaTerceros.NumeroCuenta%Type;
	nCuenta_Cargo PlanillaTerceros.Cuenta_Cargo%Type;
	xTipo number(1);
	nCuenta_Abono PlanillaTercerosIntegrantes.Cuenta_Abono%Type;
	nImporte PlanillaTercerosIntegrantes.Importe%Type;
	xCommit number(9) := 0;
	Sin_Llave exception;
	nExiste number(3) := 0;
	vRuta Syst900.TblDescri%Type;
	iPos number(9);
	fPos number(9);
	xtam number;
	xpos number;
	nError number(9) := 0;
Begin
	Set_application_property(cursor_style, 'busy');
	n := 0;
	xCommit := 0;
	/*--Select TblDescri into vRuta From Syst900 Where TblCodTab = 610 and TblCodArg = 4; -- Ruta Plla Terceros
	If Get_Application_property(USER_INTERFACE) = 'WEB' Then
	Host('Copy C:\TempUpLoad\' || :block3.Archivo || ' ' || vRuta, no_screen);
	End if;*/
	
	in_file := CLIENT_TEXT_IO.FOPEN (vNOMBREARCHIVO, 'r','ANSI');
	/*Begin
	in_file := TEXT_IO.FOPEN(vRuta || '\' || :block3.Archivo, 'r');
	Exception When Others then IM$_ALERTAMENSAJES(0,'No existe el archivo'); Raise Form_Trigger_Failure; End;
	*/
	Loop
		CLIENT_TEXT_IO.GET_LINE (in_file, linebuf);
		--
		linebuf := trim(linebuf);
		--
		Begin
			xtam :=length(linebuf);
			xpos := instr(linebuf,',');
			vOrden:= substr(linebuf,1,xpos-1);
			linebuf:=substr(linebuf,xpos+1,xtam-xpos);
			--
			xtam :=length(linebuf);
			xpos := instr(linebuf,',');
			nCuenta_Cargo:= substr(linebuf,1,xpos-1);
			linebuf:=substr(linebuf,xpos+1,xtam-xpos);
			--
			xtam :=length(linebuf);
			xpos := instr(linebuf,',');
			nCuenta_Abono:= substr(linebuf,1,xpos-1);
			linebuf:=substr(linebuf,xpos+1,xtam-xpos);
			--
			xtam :=length(linebuf);
			xpos := instr(linebuf,',');
			nImporte:= to_number(linebuf,'FM9999990.90'); --nImporte:= to_number(substr(linebuf,1,xpos-1),'FM9999990.90');
			--linebuf:=substr(linebuf,xpos+1,xtam-xpos);
			/*
			fPos := Instr(linebuf, ',', 1, 1); vOrden := trim(substr(linebuf, 1, fPos - 1));
			iPos := fPos;
			fPos := Instr(linebuf, ',', 1, 2); nCuenta_Cargo := To_Number(trim(substr(linebuf, iPos + 1, fPos - iPos - 1)));
			iPos := fPos;
			fPos := Instr(linebuf, ',', 1, 3);       
			If fPos = 0 then
				nCuenta_Abono := To_Number(trim(substr(linebuf, iPos + 1)));
				nImporte := 0;
			Else
				nCuenta_Abono := To_Number(trim(substr(linebuf, iPos + 1, fPos - iPos - 1)));
				iPos := fPos;
				fPos := Instr(linebuf, ',', 1,10); nImporte := To_number(trim(substr(linebuf, iPos + 1)));
			End if;*/
			
			--vOrden := ltrim(rtrim(substr(linebuf, 1, 6)));
			--nCuenta_Cargo := To_Number(ltrim(rtrim(substr(linebuf, 7, 12))));
			--nMoneda := To_Number(ltrim(rtrim(substr(linebuf, 19, 1))));
			--xTipo := To_Number(ltrim(rtrim(substr(linebuf, 20, 1))));
			--nCuenta_Abono := To_Number(ltrim(rtrim(substr(linebuf, 21, 12))));
			--nImporte := To_Number(ltrim(rtrim(substr(linebuf, 33, 9))));
			
			Select Count(*) into nExiste From CuentaCorriente Where NumeroCuenta = nCuenta_Cargo;
			If Nvl(nExiste, 0) = 0 then Raise Sin_Llave; End if;
			
			Select NumeroCuenta into nNumeroCuenta From CuentaCorriente
			Where GEN05130(NumeroCuenta) = GEN05130(nCuenta_Cargo) -- and TipoTransaccion = 1 -- Aportes
			and RowNum < 2
			order by numerocuenta;
			--
			Begin
				Insert into PlanillaTerceros (NumeroCuenta, Orden, Cuenta_Cargo, Moneda, OpcionDebito, Estado, CodigoUsuario, FechaUsuario)
				Values (nNumeroCuenta, vOrden, nCuenta_Cargo, 1, 0, 1, User, Sysdate);
			Exception
				When Dup_Val_On_Index then null;
				When Others then
					IM$_ALERTAMENSAJES(0,SqlErrm || ' NroCta ' || To_char(nNumeroCuenta) || ' Orden ' || vOrden || 
					' Cargo ' || To_char(nCuenta_Cargo) || ' Moneda ' || To_Char(1));
			End;
			--
			Begin
				Select Count(*) into nExiste From CuentaCorriente Where NumeroCuenta = nCuenta_Abono;
				If Nvl(nExiste, 0) = 0 then Raise Sin_Llave; End if;
				--
				Insert into PlanillaTercerosIntegrantes (NumeroCuenta, Orden, Cuenta_Abono, Importe)
				Values (nNumeroCuenta, vOrden, nCuenta_Abono, nvl(nImporte,0));
			Exception
				When Sin_Llave then
					IM$_ALERTAMENSAJES(0,' La Cuenta por Abonar no Existe, revisar los datos a procesar...' || To_char(nCuenta_Abono));    
				When Dup_Val_On_Index then null;
				When Others then
					IM$_ALERTAMENSAJES(0,SqlErrm || ' NroCta ' || To_char(nNumeroCuenta) || ' Orden ' || vOrden
					|| ' Abono ' || ltrim(rtrim(substr(linebuf, 21, 12))) || ' Importe ' || ltrim(rtrim(substr(linebuf, 33, 9))));
			End;
		Exception
			When Others then
				nError := nError + 1;
		End;
		--
		xCommit := xCommit + 1;
		--
		If xCommit >= 1000 Then Commit; xCommit := 0; End if;
		--Text_IO.New_Line;
		CLIENT_TEXT_IO.NEW_LINE;
	End Loop;
Exception
	When No_Data_Found then
		--Text_IO.FClose(in_file);
		CLIENT_TEXT_IO.FCLOSE (in_file);
		IM$_ALERTAMENSAJES(0,' Registros Procesados Satisfactoriamente..');
		If nError > 0 then IM$_ALERTAMENSAJES(0,' Existieron ' || To_char(nError) || ' errores. Verificar!'); End if;
		Set_application_property(cursor_style, 'default');
		Commit;
	When Sin_Llave then
		IM$_ALERTAMENSAJES(0,' La Cuenta para Cargar no Existe, revisar los datos a procesar...' || To_char(nCuenta_Cargo));
		ADM07070;
		--Text_IO.FClose(in_file);
		CLIENT_TEXT_IO.FCLOSE (in_file);
		Set_application_property(cursor_style, 'default');
	When Others Then
		Commit;
		IM$_ALERTAMENSAJES(0,' Error..' || SqlErrm);
		--Text_IO.FClose(in_file);
		CLIENT_TEXT_IO.FCLOSE (in_file);
		Set_application_property(cursor_style, 'default');
End;

/*

PROCEDURE CargaLiquidacion (VNOMBREarchivo varchar )IS
	N NUMBER;
	vMensaje varchar2(2000);
	NCOMMIT NUMBER;
	in_file   CLIENT_TEXT_IO.FILE_TYPE;
	linebuf   VARCHAR2 (1000);
	--nError    NUMBER (9) := 0;
	vError    VARCHAR2 (300);
	errorMsg  varchar2(300);
	nNumerocarga number;
	nCuenta varchar2(10);
	nMontos number(18,2);
	nFecmov date;
	nRefcue varchar(100);
	nConcep char;
	nRegcon varchar2(20);
	nEstado number;   
	--hError number:= 0;
	msglog varchar(1000);
	herror  number;
	nerror number;
	NN1    number;
	nn2    number;
	carga   number;
	xtam number;
	xpos number;
	n1 number;
	nrep number;
	xrep number;
	tNTARCRE plrliquidacion.NTARCRE%type;
	tMAPPASO plrliquidacion.MAPPASO%type;
	tMAPMASO plrliquidacion.MAPMASO%type;
	tMNOMSOC plrliquidacion.MNOMSOC%type;
	tCFECHA_ plrliquidacion.CFECHA_%type;
	nISALAYR plrliquidacion.ISALAYR%type;
	nISALHOY plrliquidacion.ISALHOY%type;
	nIRECAYR plrliquidacion.IRECAYR%type;
	nIDISAYR plrliquidacion.IDISAYR%type;
	nIREGAYR plrliquidacion.IREGAYR%type;
	nILIQUID plrliquidacion.ILIQUID%type;
	nPERIODOSOLICITUD plrliquidacion.PERIODOSOLICITUD%type;
	nNUMEROSOLICITUD plrliquidacion.NUMEROSOLICITUD%type;
BEGIN
	nError:= 0;
	hError:= 0;
	--
	SET_APPLICATION_PROPERTY (cursor_style, 'busy');
	--
	N := 0;
	nCommit := 0;
	--
	in_file := CLIENT_TEXT_IO.FOPEN (vNOMBREARCHIVO, 'r','ANSI');
	--
	LOOP
		CLIENT_TEXT_IO.GET_LINE (in_file, linebuf);
		--
		linebuf := trim(linebuf);
		--
		BEGIN     	
			if linebuf is not null then
				xtam :=length(linebuf);
				xpos := instr(linebuf,',');
				tNTARCRE:= substr(linebuf,1,xpos-1);
				linebuf:=substr(linebuf,xpos+1,xtam-xpos);
				--
				xtam :=length(linebuf);
				xpos := instr(linebuf,',');
				tMAPPASO:= substr(linebuf,1,xpos-1);
				linebuf:=substr(linebuf,xpos+1,xtam-xpos);
				--
				xtam :=length(linebuf);
				xpos := instr(linebuf,',');
				tMAPMASO:= substr(linebuf,1,xpos-1);
				linebuf:=substr(linebuf,xpos+1,xtam-xpos);
				--
				xtam :=length(linebuf);
				xpos := instr(linebuf,',');
				tMNOMSOC:= substr(linebuf,1,xpos-1);
				linebuf:=substr(linebuf,xpos+1,xtam-xpos);
				--
				xtam :=length(linebuf);
				xpos := instr(linebuf,',');
				tCFECHA_:= substr(linebuf,1,xpos-1);
				linebuf:=substr(linebuf,xpos+1,xtam-xpos);
				--
				xtam :=length(linebuf);
				xpos := instr(linebuf,','); -- NCAPITAL:= to_number(replace(substr(linebuf,1,xpos-1),'.',','));
				nISALAYR:= to_number(substr(linebuf,1,xpos-1),'FM9999990.90');
				linebuf:=substr(linebuf,xpos+1,xtam-xpos);
				--
				xtam :=length(linebuf);
				xpos := instr(linebuf,','); -- NINTERES:= to_number(replace(substr(linebuf,1,xpos-1),'.',','));
				nISALHOY:= to_number(substr(linebuf,1,xpos-1),'FM9999990.90');
				linebuf:=substr(linebuf,xpos+1,xtam-xpos);
				--
				xtam :=length(linebuf);
				xpos := instr(linebuf,','); -- NDESGRAVAMEN:= to_number(replace(substr(linebuf,1,xpos-1),'.',','));
				nIRECAYR:= to_number(substr(linebuf,1,xpos-1),'FM9999990.90');
				linebuf:=substr(linebuf,xpos+1,xtam-xpos);  
				--
				xtam :=length(linebuf);
				xpos := instr(linebuf,','); -- NAPORTES:= to_number(replace(substr(linebuf,1,xpos-1),'.',','));
				nIDISAYR:= to_number(substr(linebuf,1,xpos-1),'FM9999990.90');
				linebuf:=substr(linebuf,xpos+1,xtam-xpos);
				--
				xtam :=length(linebuf);
				xpos := instr(linebuf,','); -- NSEGUROINTERES:= to_number(replace(substr(linebuf,1,xpos-1),'.',','));
				nIREGAYR:= to_number(substr(linebuf,1,xpos-1),'FM9999990.90');
				linebuf:=substr(linebuf,xpos+1,xtam-xpos);
				--     
				xtam :=length(linebuf);
				xpos := instr(linebuf,',');
				nILIQUID:= to_number(substr(linebuf,1,xpos-1),'FM9999990.90');
				linebuf:=substr(linebuf,xpos+1,xtam-xpos);	
			end if;
		EXCEPTION WHEN OTHERS THEN
			im$_Alertamensajes(0,'Error: ' || SQLERRM||chr(10)|| 'Al intentar Cargar el Archivo. Formato Incompatible en la Linea N° '||n+1);
			nError:=nError +1;
		END;	
		--
		CLIENT_TEXT_IO.NEW_LINE;
	END LOOP;
EXCEPTION
	WHEN NO_DATA_FOUND then
		CLIENT_TEXT_IO.FCLOSE (in_file);
		SET_APPLICATION_PROPERTY (cursor_style, 'default');  
		--
		If hError =0 then 
			begin
		   	in_file := CLIENT_TEXT_IO.FOPEN (vNOMBREARCHIVO, 'r','ANSI');
		   	n:=0;
		   	xrep := 0;
		   	--
		   	LOOP
		      CLIENT_TEXT_IO.GET_LINE (in_file, linebuf);
		      linebuf := trim(linebuf);
		      --
					if linebuf is not null then
						xtam :=length(linebuf);
						xpos := instr(linebuf,',');
						tNTARCRE:= substr(linebuf,1,xpos-1);
						linebuf:=substr(linebuf,xpos+1,xtam-xpos);
						--
						xtam :=length(linebuf);
						xpos := instr(linebuf,',');
						tMAPPASO:= substr(linebuf,1,xpos-1);
						linebuf:=substr(linebuf,xpos+1,xtam-xpos);
						--
						xtam :=length(linebuf);
						xpos := instr(linebuf,',');
						tMAPMASO:= substr(linebuf,1,xpos-1);
						linebuf:=substr(linebuf,xpos+1,xtam-xpos);
						--
						xtam :=length(linebuf);
						xpos := instr(linebuf,',');
						tMNOMSOC:= substr(linebuf,1,xpos-1);
						linebuf:=substr(linebuf,xpos+1,xtam-xpos);
						--
						xtam :=length(linebuf);
						xpos := instr(linebuf,',');
						tCFECHA_:= substr(linebuf,1,xpos-1);
						linebuf:=substr(linebuf,xpos+1,xtam-xpos);
						--
						xtam :=length(linebuf);
						xpos := instr(linebuf,','); --NCAPITAL:= to_number(replace(substr(linebuf,1,xpos-1),'.',','));
						nISALAYR:= to_number(substr(linebuf,1,xpos-1),'FM9999990.90');
						linebuf:=substr(linebuf,xpos+1,xtam-xpos);
						--
						xtam :=length(linebuf);
						xpos := instr(linebuf,','); -- NINTERES:= to_number(replace(substr(linebuf,1,xpos-1),'.',','));
						nISALHOY:= to_number(substr(linebuf,1,xpos-1),'FM9999990.90');
						linebuf:=substr(linebuf,xpos+1,xtam-xpos);
						--
						xtam :=length(linebuf);
						xpos := instr(linebuf,','); --NDESGRAVAMEN:= to_number(replace(substr(linebuf,1,xpos-1),'.',','));
						nIRECAYR:= to_number(substr(linebuf,1,xpos-1),'FM9999990.90');
						linebuf:=substr(linebuf,xpos+1,xtam-xpos);  
						--
						xtam :=length(linebuf);
						xpos := instr(linebuf,','); -- NAPORTES:= to_number(replace(substr(linebuf,1,xpos-1),'.',','));
						nIDISAYR:= to_number(substr(linebuf,1,xpos-1),'FM9999990.90');
						linebuf:=substr(linebuf,xpos+1,xtam-xpos);
						--
						xtam :=length(linebuf);
						xpos := instr(linebuf,','); --   NSEGUROINTERES:= to_number(replace(substr(linebuf,1,xpos-1),'.',','));
						nIREGAYR:= to_number(substr(linebuf,1,xpos-1),'FM9999990.90');
						linebuf:=substr(linebuf,xpos+1,xtam-xpos);
						--     
						xtam :=length(linebuf);
						xpos := instr(linebuf,',');
						nILIQUID:= to_number(substr(linebuf,1,xpos-1),'FM9999990.90');
						linebuf:=substr(linebuf,xpos+1,xtam-xpos);
						--
						Begin
							select periodosolicitud, numerosolicitud into nperiodosolicitud, nnumerosolicitud
							from tarjetacredito tc where to_char(numerotarjetacredito) = tNTARCRE;
						Exception
							When Others Then nperiodosolicitud := NULL; nnumerosolicitud := NULL; --vMensaje := SQLErrM;
						End;
						--
						select count(*) into nCuenta from plrliquidacion where NTARCRE||CFECHA_ = tNTARCRE||tCFECHA_;
						--
						If nILIQUID>0 and nCuenta = 0 Then
							insert into plrliquidacion(NTARCRE, MAPPASO, MAPMASO, MNOMSOC, CFECHA_,
							ISALAYR, ISALHOY, IRECAYR, IDISAYR, IREGAYR, ILIQUID, CCLIENT, CSERVIC,
							NSERVIC, CMONEDA, CESTADO, PERIODOSOLICITUD, NUMEROSOLICITUD)
							values(tNTARCRE, tMAPPASO, tMAPMASO, tMNOMSOC, tCFECHA_,
							nISALAYR, nISALHOY, nIRECAYR, nIDISAYR, nIREGAYR, nILIQUID, null, null,
							null, null, 1, nPERIODOSOLICITUD, nNUMEROSOLICITUD);
							--
							commit;
							n:=n+1;
						Else
							xrep := xrep+1;
						End If;
						--
						CLIENT_TEXT_IO.NEW_LINE;
					end if;
		   	END LOOP;
			EXCEPTION	
		   	WHEN NO_DATA_FOUND then
					CLIENT_TEXT_IO.FCLOSE (in_file);
					--
					if xrep>0 then
						im$_Alertamensajes(0,'Se encontraron Registros ya cargados.'||chr(10)||
						'Total Registros Cargados: '||N||chr(10)||'Total Registros no Cargados: '||xrep);	
					else 
						im$_Alertamensajes(0,'Carga Realizada Satisfactoriamente. Total Registros Cargados.'|| N);
						GO_ITEM('block1.BT_EXAMINARCONCEPTOS');
						--set_item_property('block1.btn_procesar',enabled,property_true);
						--set_item_property('block1.PB_CARGATXT',enabled,property_false);
						GO_ITEM('block1.btn_procesar');
					end if;
					--
					IF N<>0 THEN
						null;
					END IF;
		    WHEN OTHERS THEN
					im$_Alertamensajes(0,'Error: ' || SQLERRM||chr(10)|| 'Al intentar Cargar el Archivo. Formato Incompatible en la Linea N° '||n+1);
		  END;
		Else
		 	im$_Alertamensajes(0,'No se Puede Cargar el Archivo. Total Errores: '||nError||'. Consulte el Log de Errores.');
		End If;             
	WHEN OTHERS THEN
	  vError := 'Error CargaLiquidacion: '||SQLERRM;
	  CLIENT_TEXT_IO.FCLOSE (in_file);
	  SET_APPLICATION_PROPERTY (cursor_style, 'default');  
END;
*/