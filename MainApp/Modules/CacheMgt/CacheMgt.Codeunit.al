codeunit 5282618 "ACA Cache Mgt."
{
    SingleInstance = true;

    var
        Cache: array[10] of RecordRef;
        RecordIdCache: Dictionary of [Text, RecordID];
        EnumCache: Dictionary of [Enum "ACA Cache Name", Boolean];

    procedure StoreRecordId(Name: Text; RecId: RecordId)
    begin
        if RecordIdCache.ContainsKey(Name) then
            RecordIdCache.Remove(Name);

        RecordIdCache.Add(Name, RecId);
    end;

    procedure GetRecordId(Name: Text; var RecId: RecordId)
    begin
        if not RecordIdCache.Get(Name, RecId) then
            exit;

        RecordIdCache.Remove(Name);
    end;

    procedure InitCache(CacheId: Integer; TableNo: Integer)
    begin
        Clear(Cache[CacheId]);
        Cache[CacheId].Open(TableNo, true);
    end;

    procedure ClearCache(CacheId: Integer)
    begin
        Clear(Cache[CacheId]);
    end;

    procedure InsertRecordToCache(RecordVariant: Variant)
    var
        RecRef: RecordRef;
        CacheId: Integer;
    begin
        RecRef.GetTable(RecordVariant);
        CacheId := GetCacheId(RecRef.Number());
        InsertRecordToCache(CacheId, RecRef);
    end;

    procedure InsertRecordToCache(CacheId: Integer; RecRef: RecordRef)
    begin
        if RecRef.Number() <> Cache[CacheId].Number() then
            Error('Record must be for table no. %1', Cache[CacheId].Number());

        Cache[CacheId].Init();
        TransferFields(Cache[CacheId], RecRef);
        Cache[CacheId].Insert();
    end;

    procedure InsertRecordToCache(CacheId: Integer; RecordVariant: Variant)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(RecordVariant);
        InsertRecordToCache(CacheId, RecRef);
    end;

    procedure GetCacheContent(var RecRef: RecordRef);
    var
        CacheId: Integer;
    begin
        CacheId := GetCacheId(RecRef.Number());
        GetCacheContent(CacheId, RecRef);
    end;

    procedure GetCacheContent(CacheId: Integer; var RecRef: RecordRef);
    begin
        if Cache[CacheId].Number() <> RecRef.Number() then
            exit;

        if not Cache[CacheId].FindSet() then
            exit;

        repeat
            RecRef.Init();
            TransferFields(RecRef, Cache[CacheId]);
            RecRef.Insert();
        until Cache[CacheId].Next() = 0;
    end;

    local procedure TransferFields(var Target: RecordRef; var Source: RecordRef)
    var
        CurrFieldRef: FieldRef;
        FieldIndex: Integer;
    begin
        for FieldIndex := 1 to Target.FieldCount() do begin
            CurrFieldRef := Target.FieldIndex(FieldIndex);
            if (CurrFieldRef.Class() = FieldClass::Normal) and CurrFieldRef.Active() then
                CurrFieldRef.Value(Source.FieldIndex(FieldIndex).Value());
        end;
    end;

    local procedure GetCacheId(TableNo: Integer): Integer
    var
        CacheId: Integer;
        NoCacheFoundErr: Label 'No cache found for table no. %1.', Comment = '%1 - Table No.';
    begin
        for CacheId := 1 to ArrayLen(Cache) do
            if Cache[CacheId].Number() = TableNo then
                exit(CacheId);

        Error(NoCacheFoundErr, TableNo);
    end;

    procedure SetEnumCache(CacheName: Enum "ACA Cache Name"; CacheValue: Boolean)
    begin
        if EnumCache.ContainsKey(CacheName) then
            EnumCache.Remove(CacheName);

        EnumCache.Add(CacheName, CacheValue);
    end;

    procedure GetEnumCache(CacheName: Enum "ACA Cache Name") CacheValue: Boolean
    begin
        if not EnumCache.Get(CacheName, CacheValue) then
            exit(false);
    end;

    procedure RemoveEnumCache(CacheName: Enum "ACA Cache Name")
    begin
        if not EnumCache.ContainsKey(CacheName) then
            exit;

        EnumCache.Remove(CacheName);
    end;
}
