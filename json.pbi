; +-----------------------------------+
; | PureBasic Standard Library - JSON |
; +-----------------------------------+

;-
CompilerIf (Not Defined(_PBSL_JSON_Included, #PB_Constant))
  #_PBSL_JSON_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  
  ;- - JSON Globals
  
  Global Dim JSONTypeName.s(6-1)
  JSONTypeName(#PB_JSON_Array)   = "Array"
  JSONTypeName(#PB_JSON_Boolean) = "Boolean"
  JSONTypeName(#PB_JSON_Null)    = "Null"
  JSONTypeName(#PB_JSON_Number)  = "Number"
  JSONTypeName(#PB_JSON_Object)  = "Object"
  JSONTypeName(#PB_JSON_String)  = "String"
  
  ;-
  ;- - JSON Types
  
  Macro IsJSONArray(_Node)
    (Bool(JSONType(_Node) = #PB_JSON_Array))
  EndMacro
  Macro IsJSONBoolean(_Node)
    (Bool(JSONType(_Node) = #PB_JSON_Boolean))
  EndMacro
  Macro IsJSONNull(_Node)
    (Bool(JSONType(_Node) = #PB_JSON_Null))
  EndMacro
  Macro IsJSONNumber(_Node)
    (Bool(JSONType(_Node) = #PB_JSON_Number))
  EndMacro
  Macro IsJSONObject(_Node)
    (Bool(JSONType(_Node) = #PB_JSON_Object))
  EndMacro
  Macro IsJSONString(_Node)
    (Bool(JSONType(_Node) = #PB_JSON_String))
  EndMacro
  
  Procedure.i ValidateJSONType(*JSONValue, Type.i)
    If (*JSONValue And (JSONType(*JSONValue) <> Type))
      *JSONValue = #Null
    EndIf
    ProcedureReturn (*JSONValue)
  EndProcedure
  
  ;-
  ;- - Counting Elements
  
  Macro CountJSONArrayElements(_Array)
    (JSONArraySize(_Array))
  EndMacro
  Macro CountJSONObjectMembers(_Object)
    (JSONObjectSize(_Object))
  EndMacro
  
  ;-
  ;- - Main Nodes
  
  Macro MainJSONNode(_JSON)
    (JSONValue(_JSON))
  EndMacro
  
  Procedure.i MainJSONArray(JSON.i)
    Protected *Node = JSONValue(JSON)
    If (*Node And IsJSONArray(*Node))
      ProcedureReturn (*Node)
    EndIf
    ProcedureReturn (#Null)
  EndProcedure
  
  Procedure.i MainJSONObject(JSON.i)
    Protected *Node = JSONValue(JSON)
    If (*Node And IsJSONObject(*Node))
      ProcedureReturn (*Node)
    EndIf
    ProcedureReturn (#Null)
  EndProcedure
  
  ;-
  ;- - Create Main Node
  
  Procedure.i CreateJSONArray(JSON.i, Flags.i = #Null, *Array.INTEGER = #Null)
    Protected Result.i = CreateJSON(JSON, Flags)
    If (Result)
      If (JSON = #PB_Any)
        JSON = Result
      EndIf
      SetJSONArray(JSONValue(JSON))
      If (*Array)
        *Array\i = JSONValue(JSON)
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i CreateJSONObject(JSON.i, Flags.i = #Null, *Object.INTEGER = #Null)
    Protected Result.i = CreateJSON(JSON, Flags)
    If (Result)
      If (JSON = #PB_Any)
        JSON = Result
      EndIf
      SetJSONObject(JSONValue(JSON))
      If (*Object)
        *Object\i = JSONValue(JSON)
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i RandomJSONElement(*Array)
    Protected *Result = #Null
    If (IsJSONArray(*Array))
      Protected N.i = JSONArraySize(*Array)
      If (N > 0)
        *Result = GetJSONElement(*Array, Random(N-1))
      EndIf
    EndIf
    ProcedureReturn (*Result)
  EndProcedure
  
  Procedure.i GetFirstJSONMember(*Object)
    Protected *Result = #Null
    If (*Object And IsJSONObject(*Object))
      If (ExamineJSONMembers(*Object))
        If (NextJSONMember(*Object))
          *Result = JSONMemberValue(*Object)
        EndIf
      EndIf
    EndIf
    ProcedureReturn (*Result)
  EndProcedure
  
  Procedure.i GetNextJSONMember(*Object, *CurrentMember)
    Protected *Result = #Null
    If (*Object And IsJSONObject(*Object) And *CurrentMember)
      If (ExamineJSONMembers(*Object))
        While (NextJSONMember(*Object))
          If (JSONMemberValue(*Object) = *CurrentMember)
            If (NextJSONMember(*Object))
              *Result = JSONMemberValue(*Object)
            EndIf
            Break
          EndIf
        Wend
      EndIf
    EndIf
    ProcedureReturn (*Result)
  EndProcedure
  
  ;-
  ;- - Safe Value Getters
  
  Procedure.i GetJSONBooleanSafe(*JSONValue)
    If (*JSONValue And IsJSONBoolean(*JSONValue))
      ProcedureReturn (GetJSONBoolean(*JSONValue))
    EndIf
    ProcedureReturn (#False)
  EndProcedure
  Procedure.d GetJSONDoubleSafe(*JSONValue)
    If (*JSONValue And IsJSONNumber(*JSONValue))
      ProcedureReturn (GetJSONDouble(*JSONValue))
    EndIf
    ProcedureReturn (0.0)
  EndProcedure
  Procedure.f GetJSONFloatSafe(*JSONValue)
    If (*JSONValue And IsJSONNumber(*JSONValue))
      ProcedureReturn (GetJSONFloat(*JSONValue))
    EndIf
    ProcedureReturn (0.0)
  EndProcedure
  Procedure.i GetJSONIntegerSafe(*JSONValue)
    If (*JSONValue And IsJSONNumber(*JSONValue))
      ProcedureReturn (GetJSONInteger(*JSONValue))
    EndIf
    ProcedureReturn (0)
  EndProcedure
  Procedure.q GetJSONQuadSafe(*JSONValue)
    If (*JSONValue And IsJSONNumber(*JSONValue))
      ProcedureReturn (GetJSONQuad(*JSONValue))
    EndIf
    ProcedureReturn (0)
  EndProcedure
  Procedure.s GetJSONStringSafe(*JSONValue)
    If (*JSONValue And IsJSONString(*JSONValue))
      ProcedureReturn (GetJSONString(*JSONValue))
    EndIf
    ProcedureReturn ("")
  EndProcedure
  
  ;-
  ;- - Copying Elements
  
  Procedure.i CopyJSONValue(*SourceValue, *DestinationValue)
    Protected Result.i = #False
    If (*SourceValue And *DestinationValue)
      Select (JSONType(*SourceValue))
        Case #PB_JSON_Null
          SetJSONNull(*DestinationValue)
          Result = #True
        Case #PB_JSON_Boolean
          SetJSONBoolean(*DestinationValue, GetJSONBoolean(*SourceValue))
          Result = #True
        Case #PB_JSON_String
          SetJSONString(*DestinationValue, GetJSONString(*SourceValue))
          Result = #True
        Case #PB_JSON_Number
          If (#False)
            SetJSONQuad(*DestinationValue, GetJSONQuad(*SourceValue))
          Else
            SetJSONDouble(*DestinationValue, GetJSONDouble(*SourceValue))
          EndIf
          Result = #True
          
        Case #PB_JSON_Array
          SetJSONArray(*DestinationValue)
          Protected *Child
          Protected N.i = JSONArraySize(*SourceValue)
          Protected i.i
          Result = #True
          For i = 0 To N-1
            *Child = AddJSONElement(*DestinationValue, i)
            Result = CopyJSONValue(GetJSONElement(*SourceValue, i), *Child)
            If (Not Result)
              Break
            EndIf
          Next i
          
        Case #PB_JSON_Object
          SetJSONObject(*DestinationValue)
          If (ExamineJSONMembers(*SourceValue))
            Result = #True
            While (NextJSONMember(*SourceValue))
              *Child = AddJSONMember(*DestinationValue, JSONMemberKey(*SourceValue))
              Result = CopyJSONValue(GetJSONMember(*SourceValue, JSONMemberKey(*SourceValue)), *Child)
              If (Not Result)
                Break
              EndIf
            Wend
          EndIf
          
      EndSelect
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i SetJSONArrayCopy(*JSONValue, *ArrayToCopy)
    Protected Result.i = #False
    If (*JSONValue And *ArrayToCopy And IsJSONArray(*ArrayToCopy))
      Result = CopyJSONValue(*ArrayToCopy, *JSONValue)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i SetJSONObjectCopy(*JSONValue, *ObjectToCopy)
    Protected Result.i = #False
    If (*JSONValue And *ObjectToCopy And IsJSONObject(*ObjectToCopy))
      Result = CopyJSONValue(*ObjectToCopy, *JSONValue)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  ;-
  ;- - Compose to String
  
  Macro ComposeJSONPretty(_JSON)
    ComposeJSON(_JSON, #PB_JSON_PrettyPrint)
  EndMacro
  Macro ComposeJSONTiny(_JSON)
    ComposeJSON(_JSON, #Null) ; as of PB 6.40, ComposeJSON() output already appears to be minified
  EndMacro
  
  Procedure.s ComposeJSONValue(*JSONValue, Flags.i = #Null)
    Protected Result.s = ""
    If (*JSONValue)
      Protected TempJSON.i = CreateJSON(#PB_Any)
      If (TempJSON)
        If (CopyJSONValue(*JSONValue, JSONValue(TempJSON)))
          Result = ComposeJSON(TempJSON, Flags)
        EndIf
        FreeJSON(TempJSON)
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  ;-
  ;- - Access Node by Path
  
  Procedure.i JSONNodeByPath(*ParentNode, Path.s, ChildType.i = #PB_Any, i.i = 0, j.i = 0, k.i = 0)
    Protected *Result = #Null
    If (*ParentNode)
      If (Path)
        Protected *Start.CHARACTER = @Path
        Protected *C.CHARACTER = *Start
        Protected Term.s
        While (#True)
          Select (*C\c)
            Case '[', ']', '/', #NUL
              If (*C\c = ']')
                *C + SizeOf(CHARACTER)
              EndIf
              Term = PeekS(*Start, (*C - *Start)/SizeOf(CHARACTER))
              If (PeekC(@Term) = '/')
                Term = Mid(Term, 2)
              EndIf
              If (Term = "")
                ; keep parsing...
                *Start = *C
              ElseIf (PeekC(@Term) = '[') ; Array Element
                If (JSONType(*ParentNode) = #PB_JSON_Array)
                  Protected Index.i
                  If (Term = "[]")
                    Index = i
                    i = j
                    j = k
                    k = 0
                  Else
                    Index = Val(Mid(Term, 2, Len(Term)-2))
                  EndIf
                  If ((Index >= 0) And (Index < JSONArraySize(*ParentNode)))
                    *Result = JSONNodeByPath(GetJSONElement(*ParentNode, Index), PeekS(*C), #PB_Any, i, j, k)
                    Break
                  Else
                    *Result = #Null
                    Break
                  EndIf
                Else
                  *Result = #Null
                  Break
                EndIf
              Else ; Object Member
                If (JSONType(*ParentNode) = #PB_JSON_Object)
                  *Result = JSONNodeByPath(GetJSONMember(*ParentNode, Term), PeekS(*C), #PB_Any, i, j, k)
                  Break
                Else
                  *Result = #Null
                EndIf
                Break
              EndIf
          EndSelect
          If (*C\c = #NUL)
            Break
          EndIf
          *C + SizeOf(CHARACTER)
        Wend
      Else
        *Result = *ParentNode
      EndIf
      If ((*Result) And (ChildType <> #PB_Any))
        *Result = ValidateJSONType(*Result, ChildType)
      EndIf
    EndIf
    ProcedureReturn (*Result)
  EndProcedure
  
  Macro JSONArrayByPath(_ParentNode, _Path, _i = 0, _j = 0, _k = 0)
    (JSONNodeByPath((_ParentNode), _Path, #PB_JSON_Array, (_i), (_j), (_k)))
  EndMacro
  Macro JSONBooleanByPath(_ParentNode, _Path, _i = 0, _j = 0, _k = 0)
    (JSONNodeByPath((_ParentNode), _Path, #PB_JSON_Boolean, (_i), (_j), (_k)))
  EndMacro
  Macro JSONNullByPath(_ParentNode, _Path, _i = 0, _j = 0, _k = 0)
    (JSONNodeByPath((_ParentNode), _Path, #PB_JSON_Null, (_i), (_j), (_k)))
  EndMacro
  Macro JSONNumberByPath(_ParentNode, _Path, _i = 0, _j = 0, _k = 0)
    (JSONNodeByPath((_ParentNode), _Path, #PB_JSON_Number, (_i), (_j), (_k)))
  EndMacro
  Macro JSONObjectByPath(_ParentNode, _Path, _i = 0, _j = 0, _k = 0)
    (JSONNodeByPath((_ParentNode), _Path, #PB_JSON_Object, (_i), (_j), (_k)))
  EndMacro
  Macro JSONStringByPath(_ParentNode, _Path, _i = 0, _j = 0, _k = 0)
    (JSONNodeByPath((_ParentNode), _Path, #PB_JSON_String, (_i), (_j), (_k)))
  EndMacro
  
  ;-
  ;- - Get Node's Value by Path
  
  Macro GetJSONBooleanByPath(_ParentNode, _Path, _i = 0, _j = 0, _k = 0)
    (GetJSONBooleanSafe(JSONNodeByPath((_ParentNode), _Path, #PB_JSON_Boolean, (_i), (_j), (_k))))
  EndMacro
  Macro GetJSONDoubleByPath(_ParentNode, _Path, _i = 0, _j = 0, _k = 0)
    (GetJSONDoubleSafe(JSONNodeByPath((_ParentNode), _Path, #PB_JSON_Number, (_i), (_j), (_k))))
  EndMacro
  Macro GetJSONFloatByPath(_ParentNode, _Path, _i = 0, _j = 0, _k = 0)
    (GetJSONFloatSafe(JSONNodeByPath((_ParentNode), _Path, #PB_JSON_Number, (_i), (_j), (_k))))
  EndMacro
  Macro GetJSONIntegerByPath(_ParentNode, _Path, _i = 0, _j = 0, _k = 0)
    (GetJSONIntegerSafe(JSONNodeByPath((_ParentNode), _Path, #PB_JSON_Number, (_i), (_j), (_k))))
  EndMacro
  Macro GetJSONQuadByPath(_ParentNode, _Path, _i = 0, _j = 0, _k = 0)
    (GetJSONQuadSafe(JSONNodeByPath((_ParentNode), _Path, #PB_JSON_Number, (_i), (_j), (_k))))
  EndMacro
  Macro GetJSONStringByPath(_ParentNode, _Path, _i = 0, _j = 0, _k = 0)
    GetJSONStringSafe(JSONNodeByPath((_ParentNode), _Path, #PB_JSON_String, (_i), (_j), (_k)))
  EndMacro
  
  ;-
  ;- - Validate Object Member by Type
  
  Macro JSONMemberArray(_Object, _Key)
    (ValidateJSONType(GetJSONMember((_Object), _Key), #PB_JSON_Array))
  EndMacro
  Macro JSONMemberBoolean(_Object, _Key)
    (ValidateJSONType(GetJSONMember((_Object), _Key), #PB_JSON_Boolean))
  EndMacro
  Macro JSONMemberNull(_Object, _Key)
    (ValidateJSONType(GetJSONMember((_Object), _Key), #PB_JSON_Null))
  EndMacro
  Macro JSONMemberNumber(_Object, _Key)
    (ValidateJSONType(GetJSONMember((_Object), _Key), #PB_JSON_Number))
  EndMacro
  Macro JSONMemberObject(_Object, _Key)
    (ValidateJSONType(GetJSONMember((_Object), _Key), #PB_JSON_Object))
  EndMacro
  Macro JSONMemberString(_Object, _Key)
    (ValidateJSONType(GetJSONMember((_Object), _Key), #PB_JSON_String))
  EndMacro
  
  ;-
  ;- - Directly Get Object Member's Value
  
  Macro GetJSONMemberArray(_Object, _Key)
    (JSONMemberArray((_Object), _Key))
  EndMacro
  Macro GetJSONMemberDouble(_Object, _Key)
    (GetJSONDoubleSafe(GetJSONMember((_Object), _Key)))
  EndMacro
  Macro GetJSONMemberFloat(_Object, _Key)
    (GetJSONFloatSafe(GetJSONMember((_Object), _Key)))
  EndMacro
  Macro GetJSONMemberInteger(_Object, _Key)
    (GetJSONIntegerSafe(GetJSONMember((_Object), _Key)))
  EndMacro
  Macro GetJSONMemberQuad(_Object, _Key)
    (GetJSONQuadSafe(GetJSONMember((_Object), _Key)))
  EndMacro
  Macro GetJSONMemberNull(_Object, _Key)
    (JSONMemberNull((_Object), _Key))
  EndMacro
  Macro GetJSONMemberObject(_Object, _Key)
    (JSONMemberObject((_Object), _Key))
  EndMacro
  Macro GetJSONMemberString(_Object, _Key)
    GetJSONStringSafe(GetJSONMember((_Object), _Key))
  EndMacro
  
CompilerEndIf
;-
