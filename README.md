1. 目前GUI功能  
    1. 可由GUI指令位置轉至定點。  
    2. 在GUI上可以看到範圍限制，若輸入超出範圍則不會動作，若輸入不為數字也不會動作。
    3. 可在移動時，從GUI上看到現在位置、速度。  
    4. 能直接在GUI上定義轉台轉動範圍，讓使用者使用前先定義範圍，避免不小心輸入錯誤，使轉台超過環境的物理限制損壞。  
    5. 手動輸入儀器IP功能。  
2. 目前function功能  
	1. 無
3. 目前Class與其屬性與方法
    1. ptu < handle ：為與Pan-Tilt Unit通訊的Handle Class  
	    1. properties：(GetAccess = public, SetAccess = private)
            1. PTU：與PTU通訊的tcpip物件。  
            2. Status：若有連線成功為'Connection successed'。   
            3. Pan_Resolution：Pan的解析度(degree)。    
            4. Tilt_Resolution：Tilt的解析度(degree)。  
            5. Pan_Limit：Pan的轉動範圍(degree)。   
            6. Tilt_Limit：Tilt的轉動範圍(degree)。  
		2. methods：  
            1. cmd：在MATLAB裡也可與teraterm一樣的下指令。  
            2. Initialize：在MATLAB內要能與PTU正常通訊需要先初始化。    
            3. PTResolution：得知PTU的解析度(unit : degree)。   
            4. PTLimit：得知PTU的轉動範圍(unit ： PTLimit)。  
            5. deg2pos：degree轉為PTU內部單位position。     
            6. gotoPT：轉至指定角度。   
            7. getPS：得到當前的位置與速度。    
            8. SetUserLimit：使用者定義範圍。   
            9. delete：刪除tcpip物件與ptu物件。 