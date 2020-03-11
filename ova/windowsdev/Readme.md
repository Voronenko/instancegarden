1)
In .ovf file find the line <vssd:VirtualSystemType>vmx-##</vssd:VirtualSystemType> and change the vmx-## value
to a different hw-version working with your ESXi (saying 14)

2)  https://kb.vmware.com/s/article/65205

Eliminate

```
      <Item ovf:required="false">
        <rasd:AutomaticAllocation>false</rasd:AutomaticAllocation>
        <rasd:ElementName>video</rasd:ElementName>
        <rasd:InstanceID>6</rasd:InstanceID>
        <rasd:ResourceType>24</rasd:ResourceType>
        <vmw:Config ovf:required="false" vmw:key="videoRamSizeInKB" vmw:value="262144"/>
      </Item>
```

3) If you made changes to ovf, calculate new hashsum

```
sha256sum WinDev2001Eval.ovf
``
and correct line in `.mf` file

```
SHA256(WinDev2001Eval.ovf)= 478eecaf676af87fafbbcf5cc90a1faa94f0515e204b720add9634e4c3980b82
```
