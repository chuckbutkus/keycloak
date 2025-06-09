<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=true; section>
    <#if section = "header">
        ${msg("emailVerifyTitle")}
    <#elseif section = "form">
        <div class="flex flex-col items-center justify-center w-full">
            <div class="border border-tertiary p-8 rounded-lg max-w-md w-full flex flex-col gap-6 items-center bg-base-secondary">
                <img src="${url.resourcesPath}/img/all-hands-logo.svg" alt="OpenHands Logo" width="68" height="46" />
                
                <div class="flex flex-col gap-2 w-full items-center text-center">
                    <h1 class="text-2xl font-bold">${msg("emailVerifyTitle")}</h1>
                    <p class="text-sm text-gray-500">
                        <#if verifyEmail??>
                            ${msg("emailVerifyInstruction1",verifyEmail)}
                        <#else>
                            ${msg("emailVerifyInstruction4",user.email)}
                        </#if>
                    </p>
                </div>
                
                <#if isAppInitiatedAction??>
                    <form id="kc-verify-email-form" class="${properties.kcFormClass!}" action="${url.loginAction}" method="post">
                        <div class="${properties.kcFormGroupClass!}">
                            <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}">
                                <#if verifyEmail??>
                                    <input class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonLargeClass!} w-full" type="submit" value="${msg("emailVerifyResend")}" />
                                <#else>
                                    <input class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonLargeClass!} w-full" type="submit" value="${msg("emailVerifySend")}" />
                                </#if>
                                <button class="${properties.kcButtonClass!} ${properties.kcButtonDefaultClass!} ${properties.kcButtonLargeClass!} w-full mt-3" type="submit" name="cancel-aia" value="true" formnovalidate/>${msg("doCancel")}</button>
                            </div>
                        </div>
                    </form>
                </#if>
            </div>
        </div>
    <#elseif section = "info">
        <#if !isAppInitiatedAction??>
            <div class="flex flex-col items-center justify-center w-full">
                <div class="border border-tertiary p-8 rounded-lg max-w-md w-full flex flex-col gap-6 items-center bg-base-secondary">
                    <img src="${url.resourcesPath}/img/all-hands-logo.svg" alt="OpenHands Logo" width="68" height="46" />
                    
                    <div class="flex flex-col gap-2 w-full items-center text-center">
                        <h1 class="text-2xl font-bold">${msg("emailVerifyTitle")}</h1>
                        <p class="text-sm text-gray-500">
                            ${msg("emailVerifyInstruction2")}
                        </p>
                    </div>
                    
                    <a href="${url.loginAction}" class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonLargeClass!} w-full text-center">
                        ${msg("doClickHere")} ${msg("emailVerifyInstruction3")}
                    </a>
                </div>
            </div>
        </#if>
    </#if>
</@layout.registrationLayout>