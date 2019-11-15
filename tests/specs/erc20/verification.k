requires "abstract-semantics-segmented-gas.k"
requires "edsl.k"
requires "../evm-data-map-concrete.k"
requires "evm-symbolic.k"

module VERIFICATION
    imports ABSTRACT-SEMANTICS-SEGMENTED-GAS
    imports EDSL
    imports EVM-DATA-MAP-CONCRETE
    imports EVM-SYMBOLIC

    rule #sizeWordStack ( WS , N:Int )
      => N +Int #sizeWordStack ( WS , 0 )
      requires N =/=K 0
      [lemma]

    //Rules for #padToWidth with non-regular symbolic arguments.
    rule #padToWidth(32, #asByteStack(V)) => #asByteStackInWidth(V, 32)
      requires 0 <=Int V andBool V <Int pow256 andBool #notKLabel(V, "#asWord")

    rule chop ( W0:Int +Int W1:Int ) -Word W1:Int => chop ( W0 )
      requires #rangeUInt(256, W0) andBool #rangeUInt(256, W1)
endmodule