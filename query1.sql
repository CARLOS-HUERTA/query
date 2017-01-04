**Entrar en SQLPlus como dba sin introducir password
> sqlplus "/as sysdba"

SQL> alter user nombre_usuario identified by nuevo_password;
---------------------------------------
-- Query
---------------------------------------
Procedure IM_PoblarArea Is
 x number;

Begin
 x := Populate_group('AREA');
 Populate_List('block3.CodigoArea','AREA');
End;

**Validar ultimo registro de record

LOOP  
 If :SOLICITUDPAGOSERVICIOS.sel = 1 and  :SOLICITUDPAGOSERVICIOS.estado = 4 Then      
 update SOLICITUDPAGOSERVICIOS set estado = 3, CODIGOUSUARIO = user, fechaUSUARIO=  sysdate  where CORRELATIVO = :SOLICITUDPAGOSERVICIOS.CORRELATIVO;
 commit;    c2:=c2+1;
 end if;      
 EXIT WHEN :SYSTEM.LAST_RECORD = 'TRUE';  
 NEXT_RECORD;   
 End LOOP;

**logo
SELECT L.LOGO
FROM LOGOEMPRESA L
WHERE EXISTS (SELECT 1
              FROM SYST900 S 
              WHERE S.TBLCODTAB = 500  
              AND S.TBLCODARG   = 1
              AND S.TBLDESCRI   = L.CODIGOEMPRESA);
			 
**replace
SELECT REPLACE('7123','7','3') FROM DUAL;

** IM_PRINT 
Procedure IM_PRINT Is								
	vNombreReporte varchar2(12) := 'GEN02380';							
	vCadenaParametros varchar2(200) := 'Pperiodocontrato='||TO_CHAR(:CONTRATO.PERIODOCONTRATO);							
Begin								
	Set_application_property(cursor_style,'busy');							
	vCadenaParametros := vCadenaParametros||' Pnumerocontrato='||TO_CHAR(:CONTRATO.NUMEROCONTRATO);							
	vCadenaParametros := vCadenaParametros||' Pcodigopersona='||TO_CHAR(:CONTRATO.CODIGOPERSONA);							
	vCadenaParametros := vCadenaParametros||' PARAMFORM=NO';							
	IM$_INVOCAREPORTE(null,vNombreReporte,vCadenaParametros,:parameter.CodigoUsuario); 							
	Set_application_property(cursor_style,'default');							
End;								

** Reporte en excel
DECLARE										
vCadenaParametros varchar2(200) := ' ';									
vNombreReporte varchar2(12) := 'CAR02010';									
BEGIN										
	set_application_property(cursor_style,'busy');									
	vCadenaParametros := 'PARAMFORM=NO';									
	vCadenaParametros := vCadenaParametros || ' P_CODIGOGRUPO='||:CONDICIONCOMPRACARTERA.CODIGOGRUPO;									
	vCadenaParametros := vCadenaParametros || ' P_CODIGOSUBGRUPO='||:CONDICIONCOMPRACARTERA.CODIGOSUBGRUPO;									
	vCadenaParametros := vCadenaParametros || ' P_CODIGODEPENDENCIA='||:CONDICIONCOMPRACARTERA.CODIGODEPENDENCIA;									
										
		IM_INVOCEREPORTEEXCEL(null,vNombreReporte,vCadenaParametros,USER); 								
	set_application_property(cursor_style,'default');									
END;										
										
**Reporte a pdf
Procedure IM_PRINT1 Is								
	vNombreReporte varchar2(12) := 'LOG_ERROR';							
	vCadenaParametros varchar2(200);							
Begin								
	Set_application_property(cursor_style,'busy');							
	vCadenaParametros := vCadenaParametros||' p_codigogrupo='||TO_CHAR(:block1.codigogrupo);							
	vCadenaParametros := vCadenaParametros||' p_codigosubgrupo='||TO_CHAR(:block1.codigosubgrupo);							
	vCadenaParametros := vCadenaParametros||' p_codigodependencia='||TO_CHAR(:block1.codigodependencia);							
	vCadenaParametros := vCadenaParametros||' PARAMFORM=NO';							
	IM$_INVOCAREPORTE(null,vNombreReporte,vCadenaParametros,:parameter.CodigoUsuario); 							
	Set_application_property(cursor_style,'default');							
END;								

**Fecha
TO_DATE('11/15/2016 00:00:00', 'MM/DD/YYYY HH24:MI:SS')		

** :System.Mode
Begin											
If :System.Mode Not In ('QUERY', 'ENTER-QUERY') Then										
	If :System.record_status in ('INSERT', 'NEW') then									
								
	--	For_NumeroCajas(:block1.FechaMovimiento, :block1.CodigoAgenciaCaja, :block1.PeriodoCaja, :Block1.TipoMovimiento, :block1.NumeroCaja, :block1.FechaMovimiento);								
										
		If Nvl(:block1.TipoCambio, 0) = 0 then								
			If Nvl(nTipoCambio, 0) = 0 then							
				--IM$_ALERTAMENSAJES(0,'Alerta! No se ha ingresado el T/C del dia, se usará el último ingresado');						
				:block1.TipoCambio := For_TipoCambio;						
			Else							
				:block1.TipoCambio := nTipoCambio;						
			End if;							
		End if; 										
	End if;										
End if;	
end;									

**CURSOR TIPO FETCH
Open c1;						
  Loop						
	Fetch C1 Into :Block2.PeriodoCuenta, :block2.NumeroCuenta, :block2.DebeSoles, 					
	:block2.HaberSoles, :block2.DebeDolares, :block2.HaberDolares, :Block2.CodigoAgencia;					
    Exit When C1%NotFound;						
    Next_Record;						
  End Loop;						
Close C1;						
First_Record;						

**Exception
Exception						
	When Form_Trigger_Failure then null;					
	When Others Then 					
		ADM07070;				
		IM$_ALERTAMENSAJES(0,'Error al grabar: '||SqlErrM);				
	  IM_UltimaLiquidacion;					
End;						

*******************************************************************************

Mostrar mensaje en consulta oracle	dbms_output.put_line('Texto_Mensaje');
Habilitar Trigger	ALTER TRIGGER nombre_del_trigger ENABLE;
Deshabilitar Trigger	ALTER TRIGGER nombre_del_trigger DISABLE;
Agregar 2 o mas columnas	ALTER TABLE Nombre_Tabla ADD (Campo_1 number, Campo_2 Varchar2(35))
Eliminar columna de una tabla	ALTER TABLE Nombre_Tabla DROP COLUMN Campo_1
Agregar 1 columna	ALTER TABLE Nombre_Tabla ADD Campo_1 Varchar2(35)
Cambiar el tamaño de una columna en una tabla	ALTER TABLE Nombre_Tabla MODIFY Campo_1 Varchar2(135);
Declarar variable desde campo	tVariable NombreTabla.NombreCampo%Type;
Creacion de Indices	create Tipo_Indice index Nombre_Indice on Nombre_Tabla(Campo_1, Campo_2);
Eliminar Indice	drop index Nombre_Indice;
Renombrar tabla	RENAME TABLE TABL_ANTIGUA TO TABLA_NUEVA,
Eliminar Procedimiento	DROP PROCEDURE Nombre_Esquema.Nombre_Procedimiento;
---			
	
